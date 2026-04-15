class VacationGame extends HTMLElement {
    constructor() {
        super();
        this.attachShadow({ mode: "open" });
        this.destinations = [];
        this.currentIndex = 0;
        this.liked = [];
        this._swiping = false;
        this._startX = 0;
        this._currentX = 0;
    }

    connectedCallback() {
        this.fetchDestinations();
    }

    async fetchDestinations() {
        const res = await fetch("/api/destinations");
        this.destinations = await res.json();
        this.render();
    }

    handleSwipe(like) {
        if (this._animating) return;
        this._animating = true;
        const cardWrap = this.shadowRoot.querySelector(".card-wrap");
        const dir = like ? 1 : -1;
        if (cardWrap) {
            cardWrap.style.transition = "transform 0.35s ease, opacity 0.35s ease";
            cardWrap.style.transform = `translateX(${dir * 120}%) rotate(${dir * 15}deg)`;
            cardWrap.style.opacity = "0";
            cardWrap.addEventListener("transitionend", () => {
                if (like) this.liked.push(this.destinations[this.currentIndex]);
                this.currentIndex++;
                this._animating = false;
                this.render();
            }, { once: true });
        } else {
            if (like) this.liked.push(this.destinations[this.currentIndex]);
            this.currentIndex++;
            this._animating = false;
            this.render();
        }
    }

    restart() {
        this.currentIndex = 0;
        this.liked = [];
        this.render();
    }

    render() {
        const total = this.destinations.length;
        const done = this.currentIndex >= total;

        this.shadowRoot.innerHTML = `
            <style>
                :host { display: flex; flex-direction: column; justify-content: center; max-width: 520px; margin: 0 auto; padding: 2rem 1rem; min-height: 100%; }

                .progress-bar {
                    background: rgba(255,255,255,0.2);
                    border-radius: 1rem;
                    height: 8px;
                    margin-bottom: 1.5rem;
                    overflow: hidden;
                }
                .progress-fill {
                    height: 100%;
                    border-radius: 1rem;
                    background: linear-gradient(90deg, #0ea5e9, #fbbf24);
                    transition: width 0.4s ease;
                    width: ${total > 0 ? (this.currentIndex / total) * 100 : 0}%;
                }
                .counter {
                    text-align: center;
                    font-size: 0.85rem;
                    color: rgba(255,255,255,0.65);
                    margin-bottom: 1rem;
                }

                .card-wrap {
                    cursor: grab;
                    touch-action: pan-y;
                    user-select: none;
                    -webkit-user-select: none;
                    will-change: transform;
                    position: relative;
                }
                .card-wrap:active { cursor: grabbing; }

                .swipe-hint {
                    position: absolute;
                    top: 50%;
                    transform: translateY(-50%);
                    font-size: 2.5rem;
                    font-weight: 800;
                    padding: 0.5rem 1rem;
                    border-radius: 0.75rem;
                    border: 3px solid;
                    opacity: 0;
                    pointer-events: none;
                    transition: opacity 0.1s;
                    z-index: 10;
                }
                .swipe-hint.pass { left: 1rem; color: #f43f5e; border-color: #f43f5e; background: rgba(254,226,226,0.9); }
                .swipe-hint.go { right: 1rem; color: #22c55e; border-color: #22c55e; background: rgba(220,252,231,0.9); }

                .actions {
                    display: flex;
                    justify-content: center;
                    gap: 1.5rem;
                    margin-top: 1.5rem;
                }
                .btn {
                    width: 70px;
                    height: 70px;
                    border-radius: 50%;
                    border: none;
                    font-size: 1.75rem;
                    cursor: pointer;
                    transition: transform 0.15s, box-shadow 0.15s;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }
                .btn:hover { transform: scale(1.12); }
                .btn:active { transform: scale(0.95); }
                .btn.pass {
                    background: #fee2e2;
                    box-shadow: 0 4px 15px rgba(244, 63, 94, 0.3);
                }
                .btn.go {
                    background: #dcfce7;
                    box-shadow: 0 4px 15px rgba(34, 197, 94, 0.3);
                }
                .btn-label {
                    font-size: 0.7rem;
                    text-align: center;
                    color: rgba(255,255,255,0.5);
                    margin-top: 0.25rem;
                }
                .actions-wrap { display: flex; flex-direction: column; align-items: center; }
                .swipe-tip {
                    text-align: center;
                    font-size: 0.75rem;
                    color: rgba(255,255,255,0.4);
                    margin-top: 0.75rem;
                }

                .result {
                    text-align: center;
                    padding: 2rem 1rem;
                }
                .result-emoji {
                    font-size: 5rem;
                    margin-bottom: 1rem;
                }
                .result-title {
                    font-size: 1.6rem;
                    font-weight: 800;
                    color: #fff;
                    margin-bottom: 0.5rem;
                }
                .result-sub {
                    font-size: 1.05rem;
                    color: rgba(255,255,255,0.7);
                    margin-bottom: 1.5rem;
                    font-style: italic;
                }
                .result-fact {
                    font-size: 0.9rem;
                    color: rgba(255,255,255,0.6);
                    background: rgba(255,255,255,0.1);
                    border-radius: 0.75rem;
                    padding: 0.75rem 1rem;
                    margin-bottom: 1.5rem;
                    display: inline-block;
                }
                .restart-btn {
                    padding: 0.75rem 2rem;
                    border-radius: 2rem;
                    border: 2px solid rgba(255,255,255,0.3);
                    background: rgba(255,255,255,0.1);
                    color: #fff;
                    font-size: 1rem;
                    cursor: pointer;
                    transition: all 0.2s;
                }
                .restart-btn:hover {
                    background: rgba(255,255,255,0.2);
                    border-color: rgba(255,255,255,0.5);
                }
            </style>

            ${done ? this.renderResult() : this.renderCard()}
        `;

        this.bindEvents();
    }

    renderCard() {
        const total = this.destinations.length;
        if (total === 0) return `<p style="text-align:center;color:#fff;">Cargando destinos...</p>`;

        return `
            <div class="progress-bar"><div class="progress-fill"></div></div>
            <div class="counter">${this.currentIndex + 1} de ${total}</div>
            <div class="card-wrap">
                <div class="swipe-hint pass">PASO</div>
                <div class="swipe-hint go">¡ME VOY!</div>
                <destination-card></destination-card>
            </div>
            <div class="actions">
                <div class="actions-wrap">
                    <button class="btn pass" id="btn-pass">🚫</button>
                    <div class="btn-label">Paso</div>
                </div>
                <div class="actions-wrap">
                    <button class="btn go" id="btn-go">✈️</button>
                    <div class="btn-label">¡Me voy!</div>
                </div>
            </div>
            <div class="swipe-tip">👆 Arrastra la tarjeta o usa los botones</div>
        `;
    }

    renderResult() {
        if (this.liked.length === 0) {
            return `
                <div class="result">
                    <div class="result-emoji">🏠🍿</div>
                    <div class="result-title">¡Te quedas en casa!</div>
                    <div class="result-sub">Ningún destino te convenció... ¡Netflix y mantita!</div>
                    <button class="restart-btn" id="btn-restart">🔄 Volver a jugar</button>
                </div>
            `;
        }

        const pick = this.liked[Math.floor(Math.random() * this.liked.length)];
        return `
            <div class="result">
                <div class="result-emoji">${pick.emoji}</div>
                <div class="result-title">¡Te vas a ${pick.name}!</div>
                <div class="result-sub">"${pick.tagline}"</div>
                <div class="result-fact">📌 ${pick.fun_fact}</div>
                <br><br>
                <button class="restart-btn" id="btn-restart">🔄 Volver a jugar</button>
            </div>
        `;
    }

    bindEvents() {
        const passBtn = this.shadowRoot.getElementById("btn-pass");
        const goBtn = this.shadowRoot.getElementById("btn-go");
        const restartBtn = this.shadowRoot.getElementById("btn-restart");

        if (passBtn) passBtn.addEventListener("click", () => this.handleSwipe(false));
        if (goBtn) goBtn.addEventListener("click", () => this.handleSwipe(true));
        if (restartBtn) restartBtn.addEventListener("click", () => this.restart());

        const card = this.shadowRoot.querySelector("destination-card");
        if (card) card.data = this.destinations[this.currentIndex];

        const cardWrap = this.shadowRoot.querySelector(".card-wrap");
        if (!cardWrap) return;

        const THRESHOLD = 80;

        const onStart = (x) => {
            if (this._animating) return;
            this._swiping = true;
            this._startX = x;
            this._currentX = x;
            cardWrap.style.transition = "none";
        };

        const onMove = (x) => {
            if (!this._swiping) return;
            this._currentX = x;
            const dx = this._currentX - this._startX;
            const rotation = dx * 0.08;
            const opacity = Math.max(1 - Math.abs(dx) / 400, 0.4);
            cardWrap.style.transform = `translateX(${dx}px) rotate(${rotation}deg)`;
            cardWrap.style.opacity = opacity;

            const hintPass = this.shadowRoot.querySelector(".swipe-hint.pass");
            const hintGo = this.shadowRoot.querySelector(".swipe-hint.go");
            if (hintPass) hintPass.style.opacity = dx < -30 ? Math.min((-dx - 30) / 60, 1) : 0;
            if (hintGo) hintGo.style.opacity = dx > 30 ? Math.min((dx - 30) / 60, 1) : 0;
        };

        const onEnd = () => {
            if (!this._swiping) return;
            this._swiping = false;
            const dx = this._currentX - this._startX;
            if (Math.abs(dx) > THRESHOLD) {
                this.handleSwipe(dx > 0);
            } else {
                cardWrap.style.transition = "transform 0.3s ease, opacity 0.3s ease";
                cardWrap.style.transform = "translateX(0) rotate(0)";
                cardWrap.style.opacity = "1";
                const hintPass = this.shadowRoot.querySelector(".swipe-hint.pass");
                const hintGo = this.shadowRoot.querySelector(".swipe-hint.go");
                if (hintPass) hintPass.style.opacity = 0;
                if (hintGo) hintGo.style.opacity = 0;
            }
        };

        cardWrap.addEventListener("mousedown", (e) => { e.preventDefault(); onStart(e.clientX); });
        cardWrap.addEventListener("mousemove", (e) => onMove(e.clientX));
        cardWrap.addEventListener("mouseup", onEnd);
        cardWrap.addEventListener("mouseleave", onEnd);

        cardWrap.addEventListener("touchstart", (e) => onStart(e.touches[0].clientX), { passive: true });
        cardWrap.addEventListener("touchmove", (e) => onMove(e.touches[0].clientX), { passive: true });
        cardWrap.addEventListener("touchend", onEnd);
    }
}

customElements.define("vacation-game", VacationGame);
