const elements = {
  appName: document.getElementById("app-name"),
  status: document.getElementById("service-status"),
  statusDetail: document.getElementById("service-detail"),
  version: document.getElementById("app-version"),
  environment: document.getElementById("app-environment"),
  environmentChip: document.getElementById("environment-chip"),
  connection: document.getElementById("backend-connection"),
  lastChecked: document.getElementById("last-checked"),
  runtimeState: document.getElementById("runtime-state"),
  runtimeTitle: document.getElementById("runtime-title"),
  runtimeMessage: document.getElementById("runtime-message"),
  footerVersion: document.getElementById("footer-version"),
  refreshButton: document.getElementById("refresh-button"),
  toast: document.getElementById("toast")
};

function showToast(message) {
  elements.toast.textContent = message;
  elements.toast.classList.add("show");
  window.setTimeout(() => elements.toast.classList.remove("show"), 2500);
}

function setUnavailable(message) {
  elements.status.textContent = "Unavailable";
  elements.statusDetail.textContent = message;
  elements.connection.textContent = "Offline";
  elements.runtimeState.className = "runtime-state unhealthy";
  elements.runtimeTitle.textContent = "Backend not reachable";
  elements.runtimeMessage.textContent = message;
}

async function loadDashboard() {
  elements.refreshButton.disabled = true;
  elements.refreshButton.textContent = "Refreshing…";

  try {
    // Fetch health and version information from the Express backend.
    const [healthResponse, versionResponse] = await Promise.all([
      fetch("/health"),
      fetch("/version")
    ]);

    if (!healthResponse.ok || !versionResponse.ok) {
      throw new Error("The backend returned an unsuccessful response.");
    }

    const health = await healthResponse.json();
    const version = await versionResponse.json();

    elements.appName.textContent = health.application;
    elements.status.textContent = health.status === "healthy" ? "Healthy" : health.status;
    elements.statusDetail.textContent = "Backend health check passed";
    elements.version.textContent = version.version;
    elements.footerVersion.textContent = `v${version.version}`;
    elements.environment.textContent = health.environment;
    elements.environmentChip.textContent = health.environment;
    elements.connection.textContent = "Connected";
    elements.lastChecked.textContent = `Last checked: ${new Date().toLocaleTimeString()}`;
    elements.runtimeState.className = "runtime-state healthy";
    elements.runtimeTitle.textContent = "Application responding";
    elements.runtimeMessage.textContent = "GridPulse successfully returned its health information.";

    if (health.status !== "healthy") {
      setUnavailable("The backend responded but did not report a healthy status.");
    }
  } catch (error) {
    console.error("Dashboard update failed:", error);
    setUnavailable("Could not retrieve information from the GridPulse backend.");
  } finally {
    elements.refreshButton.disabled = false;
    elements.refreshButton.innerHTML = '<span aria-hidden="true">↻</span> Refresh';
  }
}

elements.refreshButton.addEventListener("click", () => {
  loadDashboard();
  showToast("Refreshing application status");
});

loadDashboard();
