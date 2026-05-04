module.exports = {
  security: {
    sessionSecret:
      process.env.SESSION_SECRET || 'change-this-session-secret-in-production',
    sessionSecretUpcoming: process.env.SESSION_SECRET_UPCOMING,
    sessionSecretFallback: process.env.SESSION_SECRET_FALLBACK,
  },
}
