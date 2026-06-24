const ALLOWED_TYPES = new Set([
  'task',
  'project',
  'event',
  'social',
  'creative',
  'partner',
  'file',
  'warehouse',
  'finance',
  'template',
  'note',
  'share'
]);

const headers = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, x-api-key',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Content-Type': 'application/json'
};

function json(statusCode, body) {
  return { statusCode, headers, body: JSON.stringify(body) };
}

exports.handler = async function handler(event) {
  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 204, headers, body: '' };
  }

  if (event.httpMethod !== 'POST') {
    return json(405, { error: 'Method not allowed. Use POST.' });
  }

  const supabaseUrl = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  const apiToken = process.env.MARKETING_API_TOKEN;
  const defaultOwnerId = process.env.MARKETING_DEFAULT_OWNER_ID || null;

  if (!supabaseUrl || !serviceRoleKey || !apiToken) {
    return json(500, {
      error: 'Missing server configuration. Set SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY and MARKETING_API_TOKEN in Netlify environment variables.'
    });
  }

  const givenToken = (event.headers.authorization || '').replace(/^Bearer\s+/i, '') || event.headers['x-api-key'];
  if (!givenToken || givenToken !== apiToken) {
    return json(401, { error: 'Unauthorized. Send Authorization: Bearer <MARKETING_API_TOKEN>.' });
  }

  let payload;
  try {
    payload = JSON.parse(event.body || '{}');
  } catch (error) {
    return json(400, { error: 'Invalid JSON body.' });
  }

  const type = String(payload.type || '').trim();
  const data = payload.data && typeof payload.data === 'object' && !Array.isArray(payload.data) ? payload.data : null;
  const visibility = payload.visibility === 'private' ? 'private' : 'team';

  if (!ALLOWED_TYPES.has(type)) {
    return json(400, { error: 'Invalid type.', allowedTypes: Array.from(ALLOWED_TYPES) });
  }

  if (!data) {
    return json(400, { error: 'Missing data object.' });
  }

  const row = {
    type,
    data,
    visibility
  };

  if (payload.owner_id || defaultOwnerId) {
    row.owner_id = payload.owner_id || defaultOwnerId;
  }

  const response = await fetch(`${supabaseUrl.replace(/\/$/, '')}/rest/v1/marketing_items`, {
    method: 'POST',
    headers: {
      apikey: serviceRoleKey,
      Authorization: `Bearer ${serviceRoleKey}`,
      'Content-Type': 'application/json',
      Prefer: 'return=representation'
    },
    body: JSON.stringify(row)
  });

  const resultText = await response.text();
  let result;
  try {
    result = JSON.parse(resultText);
  } catch (_) {
    result = resultText;
  }

  if (!response.ok) {
    return json(response.status, { error: 'Supabase insert failed.', details: result });
  }

  return json(200, { ok: true, item: Array.isArray(result) ? result[0] : result });
};
