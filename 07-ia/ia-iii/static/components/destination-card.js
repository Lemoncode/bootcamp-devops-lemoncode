class DestinationCard extends HTMLElement {
    constructor() {
        super();
        this.attachShadow({ mode: "open" });
    }

    set data(dest) {
        this._data = dest;
        this.render();
    }

    render() {
        const d = this._data;
        this.shadowRoot.innerHTML = `
            <style>
                :host { display: block; }
                .card {
                    background: rgba(255, 255, 255, 0.95);
                    border-radius: 1.5rem;
                    padding: 2.5rem 2rem 2rem;
                    text-align: center;
                    max-width: 380px;
                    margin: 0 auto;
                    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
                    position: relative;
                    overflow: hidden;
                }
                .card::before {
                    content: '';
                    position: absolute;
                    top: 0; left: 0; right: 0;
                    height: 6px;
                    background: linear-gradient(90deg, #0ea5e9, #f43f5e, #fbbf24);
                }
                .emoji {
                    font-size: 5rem;
                    line-height: 1;
                    margin-bottom: 1rem;
                    filter: drop-shadow(0 4px 8px rgba(0,0,0,0.1));
                }
                .name {
                    font-size: 1.5rem;
                    font-weight: 800;
                    color: #1e293b;
                    margin-bottom: 0.5rem;
                }
                .tagline {
                    font-size: 1.05rem;
                    color: #64748b;
                    font-style: italic;
                    margin-bottom: 1.25rem;
                }
                .badges {
                    display: flex;
                    justify-content: center;
                    gap: 0.5rem;
                    margin-bottom: 1.25rem;
                    flex-wrap: wrap;
                }
                .badge {
                    padding: 0.3rem 0.75rem;
                    border-radius: 2rem;
                    font-size: 0.8rem;
                    font-weight: 600;
                    text-transform: uppercase;
                    letter-spacing: 0.03em;
                }
                .badge.climate {
                    background: #e0f2fe;
                    color: #0369a1;
                }
                .badge.vibe {
                    background: #fce7f3;
                    color: #be185d;
                }
                .fun-fact {
                    font-size: 0.9rem;
                    color: #475569;
                    background: #f8fafc;
                    border-radius: 0.75rem;
                    padding: 0.75rem 1rem;
                    border-left: 3px solid #fbbf24;
                }
                .fun-fact span {
                    font-weight: 600;
                    color: #b45309;
                }
            </style>
            <div class="card">
                <div class="emoji">${d.emoji}</div>
                <div class="name">${d.name}</div>
                <div class="tagline">"${d.tagline}"</div>
                <div class="badges">
                    <span class="badge climate">${d.climate}</span>
                    <span class="badge vibe">${d.vibe}</span>
                </div>
                <div class="fun-fact"><span>📌 Fun fact:</span> ${d.fun_fact}</div>
            </div>
        `;
    }
}

customElements.define("destination-card", DestinationCard);
