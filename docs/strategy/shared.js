// Dealhound Strategy Hub — shared client logic
// Persistence: localStorage, namespaced per document id.
// Registry: /docs/strategy/registry.json lists all outputs.

(function () {
  const STORAGE_KEY = "dealhound.strategy.v1";

  function loadAll() {
    try { return JSON.parse(localStorage.getItem(STORAGE_KEY) || "{}"); }
    catch { return {}; }
  }
  function saveAll(data) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
  }
  function loadDoc(docId) {
    const all = loadAll();
    return all[docId] || { items: {}, sectionNotes: {}, generalNotes: "", updatedAt: null };
  }
  function saveDoc(docId, doc) {
    const all = loadAll();
    doc.updatedAt = new Date().toISOString();
    all[docId] = doc;
    saveAll(all);
  }

  function toast(msg) {
    let el = document.querySelector(".toast");
    if (!el) {
      el = document.createElement("div");
      el.className = "toast";
      document.body.appendChild(el);
    }
    el.textContent = msg;
    el.classList.add("show");
    clearTimeout(el._t);
    el._t = setTimeout(() => el.classList.remove("show"), 1800);
  }

  function initDoc(docId) {
    const state = loadDoc(docId);

    // Decision segmented controls
    document.querySelectorAll(".item[data-item-id]").forEach((item) => {
      const id = item.dataset.itemId;
      const current = (state.items[id] && state.items[id].decision) || "";
      item.querySelectorAll(".seg button").forEach((btn) => {
        if (btn.dataset.val === current) btn.classList.add("on");
        btn.addEventListener("click", () => {
          const val = btn.dataset.val;
          item.querySelectorAll(".seg button").forEach((b) => b.classList.remove("on"));
          btn.classList.add("on");
          const d = loadDoc(docId);
          d.items[id] = Object.assign({}, d.items[id], { decision: val });
          saveDoc(docId, d);
          refreshSummary(docId);
        });
      });

      const noteEl = item.querySelector("textarea.item-note");
      if (noteEl) {
        if (state.items[id] && state.items[id].notes) noteEl.value = state.items[id].notes;
        noteEl.addEventListener("input", () => {
          const d = loadDoc(docId);
          d.items[id] = Object.assign({}, d.items[id], { notes: noteEl.value });
          saveDoc(docId, d);
        });
      }
    });

    // Section notes
    document.querySelectorAll("textarea.section-note").forEach((ta) => {
      const sec = ta.dataset.section;
      if (state.sectionNotes[sec]) ta.value = state.sectionNotes[sec];
      ta.addEventListener("input", () => {
        const d = loadDoc(docId);
        d.sectionNotes[sec] = ta.value;
        saveDoc(docId, d);
      });
    });

    // General notes
    const gen = document.querySelector("textarea.general-notes");
    if (gen) {
      gen.value = state.generalNotes || "";
      gen.addEventListener("input", () => {
        const d = loadDoc(docId);
        d.generalNotes = gen.value;
        saveDoc(docId, d);
      });
    }

    // Reset button
    const resetBtn = document.querySelector("button.action-reset");
    if (resetBtn) {
      resetBtn.addEventListener("click", () => {
        if (!confirm("Clear all your selections and notes for this document?")) return;
        const all = loadAll();
        delete all[docId];
        saveAll(all);
        location.reload();
      });
    }

    // Generate feedback prompt
    const genBtn = document.querySelector("button.action-generate");
    if (genBtn) {
      genBtn.addEventListener("click", () => openFeedbackDialog(docId));
    }

    refreshSummary(docId);
  }

  function refreshSummary(docId) {
    const state = loadDoc(docId);
    const counts = { adopt: 0, adapt: 0, skip: 0, undecided: 0 };
    document.querySelectorAll(".item[data-item-id]").forEach((item) => {
      const d = state.items[item.dataset.itemId];
      const v = (d && d.decision) || "undecided";
      counts[v] = (counts[v] || 0) + 1;
    });
    const totalEl = document.querySelector("[data-summary-total]");
    if (totalEl) {
      totalEl.querySelector("[data-c-adopt]").textContent = counts.adopt;
      totalEl.querySelector("[data-c-adapt]").textContent = counts.adapt;
      totalEl.querySelector("[data-c-skip]").textContent = counts.skip;
      totalEl.querySelector("[data-c-undecided]").textContent = counts.undecided;
    }
  }

  function buildPrompt(docId) {
    const state = loadDoc(docId);
    const title = document.querySelector("h1") ? document.querySelector("h1").textContent.trim() : docId;

    const lines = [];
    lines.push(`I've reviewed the strategy outline "${title}" at docs/strategy/research/${docId}.html.`);
    lines.push(`Here are my decisions and notes — please incorporate them into the next deliverable.`);
    lines.push("");

    const sections = {};
    document.querySelectorAll(".item[data-item-id]").forEach((item) => {
      const sec = item.dataset.section || "General";
      const id = item.dataset.itemId;
      const title = item.querySelector("h3") ? item.querySelector("h3").textContent.trim() : id;
      const d = state.items[id] || {};
      const decision = d.decision || "undecided";
      const note = (d.notes || "").trim();
      if (!sections[sec]) sections[sec] = [];
      sections[sec].push({ title, decision, note });
    });

    Object.keys(sections).forEach((sec) => {
      lines.push(`## ${sec}`);
      sections[sec].forEach((it) => {
        const marker = it.decision === "adopt" ? "[ADOPT]" : it.decision === "adapt" ? "[ADAPT]" : it.decision === "skip" ? "[SKIP]" : "[UNDECIDED]";
        lines.push(`- ${marker} ${it.title}${it.note ? "  — " + it.note : ""}`);
      });
      const sn = (state.sectionNotes[sec] || "").trim();
      if (sn) {
        lines.push(`  Section notes: ${sn}`);
      }
      lines.push("");
    });

    const gen = (state.generalNotes || "").trim();
    if (gen) {
      lines.push("## Overall notes");
      lines.push(gen);
      lines.push("");
    }

    lines.push("## Next step");
    lines.push("Based on the [ADOPT] and [ADAPT] items, draft the next deliverable for Dealhound and save it under docs/strategy/ alongside the source outline.");

    return lines.join("\n");
  }

  function openFeedbackDialog(docId) {
    let dlg = document.querySelector("dialog.feedback");
    if (!dlg) {
      dlg = document.createElement("dialog");
      dlg.className = "feedback";
      dlg.innerHTML = `
        <div class="head">
          <h3>Feedback prompt — copy and paste this back to Claude</h3>
          <button class="btn ghost" data-close>Close</button>
        </div>
        <div class="body"><textarea readonly></textarea></div>
        <div class="foot">
          <button class="btn" data-copy>Copy to clipboard</button>
          <button class="btn primary" data-close>Done</button>
        </div>`;
      document.body.appendChild(dlg);
      dlg.querySelectorAll("[data-close]").forEach((b) => b.addEventListener("click", () => dlg.close()));
      dlg.querySelector("[data-copy]").addEventListener("click", () => {
        const ta = dlg.querySelector("textarea");
        ta.select();
        navigator.clipboard.writeText(ta.value).then(
          () => toast("Copied to clipboard"),
          () => { document.execCommand("copy"); toast("Copied"); }
        );
      });
    }
    dlg.querySelector("textarea").value = buildPrompt(docId);
    dlg.showModal();
  }

  // Hub: load registry and render cards
  async function initHub() {
    const grid = document.querySelector(".hub-grid");
    if (!grid) return;
    try {
      const res = await fetch("registry.json", { cache: "no-store" });
      const reg = await res.json();
      if (!reg.outputs || reg.outputs.length === 0) {
        grid.innerHTML = '<div class="empty">No strategy outputs yet. Ask Claude to draft one.</div>';
        return;
      }
      const state = loadAll();
      grid.innerHTML = reg.outputs.map((o) => {
        const s = state[o.id] || {};
        const updated = s.updatedAt ? new Date(s.updatedAt).toLocaleDateString() : "no decisions yet";
        return `
          <a class="hub-card" href="${o.path}">
            <div class="title">${o.title}</div>
            <div class="desc">${o.description || ""}</div>
            <div class="tags">
              <span class="tag">${o.type}</span>
              <span class="tag">${o.topic}</span>
              <span class="tag">status: ${o.status}</span>
              <span class="tag">your notes: ${updated}</span>
            </div>
          </a>`;
      }).join("");
    } catch (e) {
      grid.innerHTML = `<div class="empty">Could not load registry.json (${e.message}). If you opened this file directly (file://), serve the folder over http instead.</div>`;
    }
  }

  window.DH = { initDoc, initHub, buildPrompt, openFeedbackDialog };
})();