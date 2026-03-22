class StickerCard extends HTMLElement {
    constructor() {
        super();
        this.attachShadow({ mode: "open" });
    }

    set data(sticker) {
        this._sticker = sticker;
        this.render();
    }

    render() {
        const s = this._sticker;
        this.shadowRoot.innerHTML = `
            <style>
                :host {
                    display: block;
                }
                .card {
                    background: #1e1e3f;
                    border: 1px solid #2d2d5e;
                    border-radius: 1rem;
                    padding: 1.5rem;
                    text-align: center;
                    transition: transform 0.2s, box-shadow 0.2s;
                    cursor: default;
                }
                .card:hover {
                    transform: translateY(-4px);
                    box-shadow: 0 8px 24px rgba(76, 29, 149, 0.3);
                    border-color: #7c3aed;
                }
                .emoji {
                    font-size: 3.5rem;
                    line-height: 1;
                    margin-bottom: 0.75rem;
                }
                .name {
                    font-size: 1rem;
                    font-weight: 600;
                    color: #e2e8f0;
                    margin-bottom: 0.25rem;
                }
                .description {
                    font-size: 0.8rem;
                    color: #94a3b8;
                    margin-bottom: 0.75rem;
                }
                .category {
                    display: inline-block;
                    padding: 0.2rem 0.6rem;
                    border-radius: 1rem;
                    font-size: 0.7rem;
                    background: #4c1d95;
                    color: #c4b5fd;
                }
            </style>
            <div class="card">
                <div class="emoji">${s.emoji}</div>
                <div class="name">${s.name}</div>
                <div class="description">${s.description}</div>
                <span class="category">${s.category}</span>
            </div>
        `;
    }
}

customElements.define("sticker-card", StickerCard);
