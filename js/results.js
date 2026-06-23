const stateElement = document.getElementById("results-state");
const countElement = document.getElementById("results-count");
const tableWrapElement = document.getElementById("results-table-wrap");
const resultsBodyElement = document.getElementById("results-body");

function setState(message, isError = false) {
  stateElement.textContent = message;
  stateElement.classList.toggle("results-state--error", isError);
}

function renderResults(results) {
  resultsBodyElement.innerHTML = "";

  results.forEach((result) => {
    const row = document.createElement("tr");
    const nameCell = document.createElement("td");
    const typeCell = document.createElement("td");
    const typeBadge = document.createElement("span");

    nameCell.textContent = result.name || "未命名";
    typeBadge.className = "type-badge";
    typeBadge.textContent = result.type || "-";
    typeCell.appendChild(typeBadge);

    row.append(nameCell, typeCell);
    resultsBodyElement.appendChild(row);
  });
}

async function loadResults() {
  try {
    const response = await fetch("/api/results");

    if (!response.ok) {
      let detail = response.statusText;
      try {
        const payload = await response.json();
        detail = payload.hint || payload.error || detail;
      } catch (error) {
        // Keep the HTTP status text when the server does not return JSON.
      }

      throw new Error(detail);
    }

    const results = await response.json();
    countElement.textContent = `${results.length} 筆結果`;

    if (results.length === 0) {
      tableWrapElement.classList.add("hidden");
      setState("目前還沒有測驗結果。");
      return;
    }

    renderResults(results);
    stateElement.classList.add("hidden");
    tableWrapElement.classList.remove("hidden");
  } catch (error) {
    countElement.textContent = "讀取失敗";
    tableWrapElement.classList.add("hidden");
    setState(`無法讀取測驗結果：${error.message}`, true);
    console.error("Failed to load MBTI results:", error);
  }
}

loadResults();
