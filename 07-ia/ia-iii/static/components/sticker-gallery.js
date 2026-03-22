class StickerGallery extends HTMLElement {
    constructor() {
        super();
        this.attachShadow({ mode: "open" });
        this._stickers = [];
        this._filter = "all";
    }

    connectedCallback() {
        this.fetchStickers();
    }

    async fetchStickers() {
        const res = await fetch("/api/stickers");
        this._stickers = await res.json();
        this.buildFilters();
        this.render();
    }

    buildFilters() {
        const categories = [...new Set(this._stickers.map(s => s.category))];
        const container = document.getElementById("filters");

        categories.forEach(cat => {
            const btn = document.createElement("button");
            btn.textContent = cat;
            btn.dataset.category = cat;
            container.appendChild(btn);
        });

        container.addEventListener("click", (e) => {
            if (e.target.tagName !== "BUTTON") return;
            container.querySelectorAll("button").forEach(b => b.classList.remove("active"));
            e.target.classList.add("active");
            this._filter = e.target.dataset.category;
            this.render();
        });
    }

    render() {
        const filtered = this._filter === "all"
            ? this._stickers
            : this._stickers.filter(s => s.category === this._filter);

        this.shadowRoot.innerHTML = `
            <style>
                :host {
                    display: block;
                    padding: 0 2rem 2rem;
                }
                .grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
                    gap: 1rem;
                    max-width: 1000px;
                    margin: 0 auto;
                }
            </style>
            <div class="grid"></div>
        `;

        const grid = this.shadowRoot.querySelector(".grid");
        filtered.forEach(sticker => {
            const card = document.createElement("sticker-card");
            card.data = sticker;
            grid.appendChild(card);
        });
    }
}

customElements.define("sticker-gallery", StickerGallery);
