import { useState } from 'preact/hooks';
import { batch } from '@preact/signals';
import { view, sbaLeads, activeSbaLeadId, previewOpen } from '../lib/state.js';
import { submitSbaBuyBox } from '../lib/api.js';

export function SbaBuyBox() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [city, setCity] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      await submitSbaBuyBox({
        vertical: 'dental',
        state: 'TX',
        city: city || null,
        leadCount: 20
      });

      // Route to leads view
      batch(() => {
        if (sbaLeads.value.length > 0) {
          activeSbaLeadId.value = sbaLeads.value[0].id;
          view.value = 'sba-lead';
          previewOpen.value = true;
        } else {
          view.value = 'sba-leads';
        }
      });
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div class="sba-buybox">
      <div class="sba-buybox-card">
        <div class="sba-buybox-badge">SBA Acquisition Scanner</div>
        <h2 class="sba-buybox-title">Find dental practices<br />ready for transition</h2>
        <p class="sba-buybox-subtitle">
          Our AI scores retirement likelihood across 13 signals — from license age to digital presence decay.
        </p>
        <form class="sba-buybox-form" onSubmit={handleSubmit}>
          <div class="sba-buybox-field">
            <label>Vertical</label>
            <input type="text" value="Dental" disabled />
          </div>
          <div class="sba-buybox-field">
            <label>State</label>
            <input type="text" value="Texas" disabled />
          </div>
          <div class="sba-buybox-field">
            <label>City <span class="sba-optional">(optional)</span></label>
            <input
              type="text"
              placeholder="Any city in TX"
              value={city}
              onInput={(e) => setCity(e.target.value)}
              disabled={loading}
            />
          </div>
          <div class="sba-buybox-field">
            <label>Lead count</label>
            <input type="text" value="20" disabled />
          </div>
          <button type="submit" class="btn-primary sba-buybox-submit" disabled={loading}>
            {loading ? 'Scanning...' : 'Find Practices'}
          </button>
        </form>
        {error && <p class="sba-buybox-error">{error}</p>}
      </div>
    </div>
  );
}
