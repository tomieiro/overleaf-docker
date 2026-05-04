module.exports = {
  security: {
    sessionSecret:
      process.env.SESSION_SECRET || 'change-this-session-secret-in-production',
    sessionSecretUpcoming: process.env.SESSION_SECRET_UPCOMING,
    sessionSecretFallback: process.env.SESSION_SECRET_FALLBACK,
  },
  apis: {
    clsi: {
      url: 'http://127.0.0.1:3013',
      downloadHost: 'http://127.0.0.1',
    },
  },
}
