/**
 * requireFields(...fields) — Express middleware that validates the request body
 * has all specified fields present and non-empty.
 *
 * Usage:
 *   router.post('/route', requireFields('name', 'email'), handler);
 */
function requireFields(...fields) {
  return (req, res, next) => {
    const missing = fields.filter((f) => {
      const val = req.body[f];
      return val === undefined || val === null || String(val).trim() === '';
    });
    if (missing.length > 0) {
      return res.status(400).json({
        success: false,
        message: `Missing required fields: ${missing.join(', ')}`,
      });
    }
    next();
  };
}

module.exports = { requireFields };
