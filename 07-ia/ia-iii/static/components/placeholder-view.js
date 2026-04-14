class PlaceholderView extends HTMLElement {
  static get observedAttributes() {
    return ["section", "icon", "description"];
  }

  constructor() {
    super();
    this.attachShadow({ mode: "open" });
  }

  connectedCallback() {
    this.render();
  }

  attributeChangedCallback() {
    this.render();
  }

  render() {
    const section = this.getAttribute("section") || "Sección";
    const icon = this.getAttribute("icon") || "🚧";
    const description =
      this.getAttribute("description") || "Esta sección está en construcción";

    this.shadowRoot.innerHTML = `
      <style>
        :host {
          display: flex;
          justify-content: center;
          align-items: center;
          min-height: 60vh;
          padding: 2rem;
        }
        .placeholder {
          text-align: center;
          background: rgba(255, 255, 255, 0.08);
          border: 2px dashed rgba(255, 255, 255, 0.2);
          border-radius: 1.5rem;
          padding: 3rem 2rem;
          max-width: 420px;
          width: 100%;
        }
        .icon {
          font-size: 4rem;
          margin-bottom: 1rem;
        }
        h2 {
          font-size: 1.5rem;
          color: #e2e8f0;
          margin-bottom: 0.75rem;
        }
        p {
          color: #94a3b8;
          font-size: 1rem;
          line-height: 1.5;
        }
      </style>
      <div class="placeholder">
        <div class="icon">${icon}</div>
        <h2>${section}</h2>
        <p>${description}</p>
      </div>
    `;
  }
}

customElements.define("placeholder-view", PlaceholderView);
