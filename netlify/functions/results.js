const jsonHeaders = {
  "Content-Type": "application/json"
};

function jsonResponse(statusCode, body, headers = {}) {
  return {
    statusCode,
    headers: {
      ...jsonHeaders,
      ...headers
    },
    body: JSON.stringify(body)
  };
}

async function getDatabaseClient() {
  try {
    const { getDatabase } = await import("@netlify/database");
    const db = getDatabase();

    if (!db || typeof db.sql !== "function") {
      throw new Error("getDatabase() did not return a SQL client");
    }

    return db;
  } catch (error) {
    throw new Error(`Netlify Database is not configured: ${error.message}`);
  }
}

function isValidType(type) {
  return typeof type === "string" && /^[EI][SN][TF][JP]$/.test(type);
}

function validateResultPayload(payload) {
  return (
    payload &&
    typeof payload.name === "string" &&
    payload.name.trim().length > 0 &&
    isValidType(payload.type) &&
    payload.totals &&
    Array.isArray(payload.questionIds) &&
    Array.isArray(payload.answers)
  );
}

exports.handler = async (event) => {
  if (event.httpMethod === "OPTIONS") {
    return {
      statusCode: 204,
      headers: jsonHeaders
    };
  }

  const query = event.queryStringParameters || {};
  if (event.httpMethod === "GET" && query.health === "1") {
    try {
      const db = await getDatabaseClient();
      await db.sql`select 1`;
      return jsonResponse(200, {
        ok: true,
        function: "results",
        netlifyDatabaseConfigured: true
      });
    } catch (error) {
      return jsonResponse(500, {
        ok: false,
        function: "results",
        netlifyDatabaseConfigured: false,
        error: error.message,
        hint: "Create a built-in Netlify Database for this site, keep @netlify/database installed, and redeploy so Functions receive the database connection."
      });
    }
  }

  let db;
  try {
    db = await getDatabaseClient();
  } catch (error) {
    return jsonResponse(500, {
      error: error.message,
      hint: "Create a built-in Netlify Database for this site, then redeploy so the Function can access it."
    });
  }

  if (event.httpMethod === "POST") {
    let payload;
    try {
      payload = JSON.parse(event.body || "{}");
    } catch (error) {
      return jsonResponse(400, { error: "Invalid JSON payload" });
    }

    if (!validateResultPayload(payload)) {
      return jsonResponse(400, { error: "Invalid result payload" });
    }

    try {
      const rows = await db.sql`
        insert into mbti_results (name, type, totals, question_ids, answers)
        values (
          ${payload.name.trim().slice(0, 80)},
          ${payload.type},
          ${JSON.stringify(payload.totals)},
          ${JSON.stringify(payload.questionIds)},
          ${JSON.stringify(payload.answers)}
        )
        returning id
      `;

      return jsonResponse(201, { id: rows[0].id });
    } catch (error) {
      return jsonResponse(500, { error: error.message });
    }
  }

  if (event.httpMethod === "GET") {
    try {
      const rows = await db.sql`
        select id, name, type, totals, question_ids, answers, created_at
        from mbti_results
        order by created_at desc
        limit 100
      `;

      return jsonResponse(200, rows);
    } catch (error) {
      return jsonResponse(500, { error: error.message });
    }
  }

  return jsonResponse(405, { error: "Method not allowed" }, { Allow: "GET, POST, OPTIONS" });
};
