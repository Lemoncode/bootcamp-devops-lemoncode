const ROUTES = {
  jugar: {
    label: "Jugar",
    icon: "🎮",
    component: "vacation-game",
    description: "Vuelve a la experiencia principal",
  },
  destinos: {
    label: "Destinos",
    icon: "🌍",
    component: "placeholder-view",
    description: "Ver todos los destinos (listado / filtros)",
  },
  "mis-destinos": {
    label: "Mis destinos",
    icon: "📁",
    component: "placeholder-view",
    description: "Gestionar, editar, ordenar favoritos",
  },
  crear: {
    label: "Crear",
    icon: "➕",
    component: "placeholder-view",
    description: "Añadir un nuevo destino",
  },
  estadisticas: {
    label: "Estadísticas",
    icon: "📊",
    component: "placeholder-view",
    description: "Tus datos, rankings, insights",
  },
  admin: {
    label: "Admin",
    icon: "⚙️",
    component: "placeholder-view",
    description: "Moderar · Editar global · Configuración",
  },
};

class AppRouter extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: "open" });
  }

  connectedCallback() {
    this.shadowRoot.innerHTML = `
      <style>
        :host { display: block; width: 100%; }
        #view-container { width: 100%; }
      </style>
      <div id="view-container"></div>
    `;

    window.addEventListener("hashchange", () => this.navigate());
    this.navigate();
  }

  navigate() {
    const hash = location.hash.replace("#", "") || "jugar";
    const route = ROUTES[hash];

    if (!route) {
      location.hash = "jugar";
      return;
    }

    // Update active nav item
    document.querySelectorAll(".nav-item").forEach((item) => {
      item.classList.toggle("active", item.dataset.route === hash);
    });

    const container = this.shadowRoot.getElementById("view-container");
    container.innerHTML = "";

    if (route.component === "vacation-game") {
      container.appendChild(document.createElement("vacation-game"));
    } else {
      const view = document.createElement("placeholder-view");
      view.setAttribute("section", route.label);
      view.setAttribute("icon", route.icon);
      view.setAttribute("description", route.description);
      container.appendChild(view);
    }
  }
}

customElements.define("app-router", AppRouter);
