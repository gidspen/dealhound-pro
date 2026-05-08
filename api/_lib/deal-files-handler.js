const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

const ALLOWED_MIME = new Set([
  'application/pdf',
  'application/vnd.ms-excel',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'text/csv',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
]);

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');

  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }

  // GET ?deal_id=...&email=...
  if (req.method === 'GET') {
    const { deal_id, email } = req.query;
    if (!deal_id || !email) {
      return res.status(400).json({ error: 'Missing deal_id or email' });
    }

    const { data, error } = await supabase
      .from('deal_financial_files')
      .select('id, file_name, file_type, file_size_bytes, upload_source, created_at, storage_path')
      .eq('deal_id', deal_id)
      .eq('user_email', email)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('deal-files GET error:', error.message);
      return res.status(500).json({ error: 'Failed to load files' });
    }

    return res.status(200).json({ files: data || [] });
  }

  // POST — upload file (base64 in JSON body)
  if (req.method === 'POST') {
    const { deal_id, email, file_name, file_type, file_data_base64 } = req.body;

    if (!deal_id || !email || !file_name || !file_data_base64) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    if (file_type && !ALLOWED_MIME.has(file_type)) {
      return res.status(400).json({ error: 'File type not allowed. Upload PDF, Excel, Word, or CSV.' });
    }

    const buffer = Buffer.from(file_data_base64, 'base64');
    if (buffer.length > 52428800) {
      return res.status(400).json({ error: 'File too large. Max 50MB.' });
    }

    const safeFileName = file_name.replace(/[^a-zA-Z0-9._-]/g, '_');
    const uuid = crypto.randomUUID();
    const storage_path = `${deal_id}/${uuid}-${safeFileName}`;

    const { error: storageErr } = await supabase.storage
      .from('deal-financials')
      .upload(storage_path, buffer, {
        contentType: file_type || 'application/octet-stream',
        upsert: false,
      });

    if (storageErr) {
      console.error('deal-files storage upload error:', storageErr.message);
      return res.status(500).json({ error: 'Storage upload failed' });
    }

    const { data, error: dbErr } = await supabase
      .from('deal_financial_files')
      .insert({
        deal_id,
        user_email: email,
        file_name,
        file_type: file_type || null,
        storage_path,
        file_size_bytes: buffer.length,
        upload_source: 'user_upload',
        parsed: false,
      })
      .select('id, file_name, file_type, file_size_bytes, upload_source, created_at, storage_path')
      .single();

    if (dbErr) {
      await supabase.storage.from('deal-financials').remove([storage_path]);
      console.error('deal-files DB insert error:', dbErr.message);
      return res.status(500).json({ error: 'Failed to save file record' });
    }

    return res.status(200).json({ file: data });
  }

  // DELETE ?id=...&email=...
  if (req.method === 'DELETE') {
    const { id, email } = req.query;
    if (!id || !email) {
      return res.status(400).json({ error: 'Missing id or email' });
    }

    const { data: file, error: fetchErr } = await supabase
      .from('deal_financial_files')
      .select('storage_path, user_email')
      .eq('id', id)
      .eq('user_email', email)
      .single();

    if (fetchErr || !file) {
      return res.status(404).json({ error: 'File not found' });
    }

    if (file.storage_path) {
      await supabase.storage.from('deal-financials').remove([file.storage_path]);
    }

    const { error: deleteErr } = await supabase
      .from('deal_financial_files')
      .delete()
      .eq('id', id)
      .eq('user_email', email);

    if (deleteErr) {
      console.error('deal-files DELETE error:', deleteErr.message);
      return res.status(500).json({ error: 'Failed to delete file' });
    }

    return res.status(200).json({ ok: true });
  }

  return res.status(405).json({ error: 'Method not allowed' });
};
