const express = require("express");
const path = require("path");

const app = express();

const APP_NAME = "GridPulse";
const APP_VERSION = process.env.APP_VERSION || "1.0.0";
const APP_ENV = process.env.NODE_ENV || "development";
const PORT = Number(process.env.PORT) || 3000;

// Serve the frontend files from the public directory.
app.use(express.static(path.join(__dirname, "public")));

// Health endpoint: used to check whether the application is responding.
app.get("/health", (req, res) => {
  res.status(200).json({
    application: APP_NAME,
    status: "healthy",
    version: APP_VERSION,
    environment: APP_ENV
  });
});

// Version endpoint: reports the version of the running application.
app.get("/version", (req, res) => {
  res.status(200).json({
    application: APP_NAME,
    version: APP_VERSION
  });
});

// Return a JSON response for routes that do not exist.
app.use((req, res) => {
  res.status(404).json({
    error: "Not Found",
    message: `The route ${req.originalUrl} does not exist.`
  });
});

// Basic error handler. Keep this after routes and other middleware.
app.use((err, req, res, next) => {
  console.error("Application error:", err);
  res.status(500).json({
    error: "Internal Server Error",
    message: "Something went wrong."
  });
});

// Export the app so automated tests can start it on a temporary port.
module.exports = app;

// Start the server only when this file is run directly.
if (require.main === module) {
  app.listen(PORT, "0.0.0.0", () => {
    console.log(`${APP_NAME} is running on port ${PORT}`);
    console.log(`Environment: ${APP_ENV}`);
    console.log(`Version: ${APP_VERSION}`);
  });
}
