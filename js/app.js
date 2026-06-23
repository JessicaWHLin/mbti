const QUIZ_LENGTH = 30;
const DIMENSIONS = ["EI", "SN", "TF", "JP"];

const state = {
  questions: [],
  mbtiTypes: {},
  answerScale: [],
  currentIndex: 0,
  answers: [],
  userName: ""
};

const screens = {
  intro: document.getElementById("intro-screen"),
  quiz: document.getElementById("quiz-screen"),
  result: document.getElementById("result-screen")
};

const elements = {
  userNameInput: document.getElementById("user-name"),
  startButton: document.getElementById("start-button"),
  nameError: document.getElementById("name-error"),
  prevButton: document.getElementById("prev-button"),
  restartButton: document.getElementById("restart-button"),
  questionCounter: document.getElementById("question-counter"),
  dimensionTag: document.getElementById("dimension-tag"),
  progressBar: document.getElementById("progress-bar"),
  questionText: document.getElementById("question-text"),
  quizForm: document.getElementById("quiz-form"),
  helperText: document.getElementById("helper-text"),
  optionTemplate: document.getElementById("option-template"),
  resultName: document.getElementById("result-name"),
  resultType: document.getElementById("result-type"),
  resultTitle: document.getElementById("result-title"),
  resultSummary: document.getElementById("result-summary"),
  saveStatus: document.getElementById("save-status"),
  dimensionGrid: document.getElementById("dimension-grid"),
  strengthsList: document.getElementById("strengths-list"),
  challengesList: document.getElementById("challenges-list"),
  rolesList: document.getElementById("roles-list"),
  roleReason: document.getElementById("role-reason"),
  workstyleText: document.getElementById("workstyle-text"),
  communicationText: document.getElementById("communication-text"),
  stressText: document.getElementById("stress-text")
};

const dimensionLabels = {
  EI: ["外向 E", "內向 I"],
  SN: ["實感 S", "直覺 N"],
  TF: ["思考 T", "情感 F"],
  JP: ["判斷 J", "感知 P"]
};

function loadData() {
  state.questions = window.MBTI_QUESTIONS || [];
  state.mbtiTypes = window.MBTI_TYPES || {};
  state.answerScale = window.MBTI_ANSWER_SCALE || [];

  if (state.questions.length < QUIZ_LENGTH || Object.keys(state.mbtiTypes).length === 0) {
    throw new Error("MBTI data not found");
  }
}

function showScreen(name) {
  Object.values(screens).forEach((screen) => screen.classList.add("hidden"));
  screens[name].classList.remove("hidden");
}

function shuffleArray(items) {
  const result = [...items];
  for (let index = result.length - 1; index > 0; index -= 1) {
    const swapIndex = Math.floor(Math.random() * (index + 1));
    [result[index], result[swapIndex]] = [result[swapIndex], result[index]];
  }
  return result;
}

function getQuestionQuotas() {
  const base = Math.floor(QUIZ_LENGTH / DIMENSIONS.length);
  const extra = QUIZ_LENGTH % DIMENSIONS.length;
  const dimensionsWithExtra = shuffleArray(DIMENSIONS).slice(0, extra);

  return DIMENSIONS.reduce((quotas, dimension) => {
    quotas[dimension] = base + (dimensionsWithExtra.includes(dimension) ? 1 : 0);
    return quotas;
  }, {});
}

function buildQuestionSequence(sourceQuestions) {
  const groupedQuestions = sourceQuestions.reduce((groups, question) => {
    if (!groups[question.dimension]) {
      groups[question.dimension] = [];
    }
    groups[question.dimension].push(question);
    return groups;
  }, {});

  const quotas = getQuestionQuotas();
  const selectedQuestions = DIMENSIONS.flatMap((dimension) => {
    const pool = shuffleArray(groupedQuestions[dimension] || []);
    return pool.slice(0, quotas[dimension]);
  });

  return shuffleArray(selectedQuestions);
}

function startQuiz() {
  const userName = elements.userNameInput.value.trim();

  if (!userName) {
    elements.nameError.textContent = "請先輸入姓名再開始測驗。";
    elements.userNameInput.focus();
    return;
  }

  state.userName = userName;
  state.currentIndex = 0;
  state.questions = buildQuestionSequence(window.MBTI_QUESTIONS || []);
  state.answers = new Array(state.questions.length).fill(null);
  elements.nameError.textContent = "";
  showScreen("quiz");
  renderQuestion();
}

function renderQuestion() {
  const question = state.questions[state.currentIndex];
  const currentAnswer = state.answers[state.currentIndex];

  elements.questionCounter.textContent = `第 ${state.currentIndex + 1} 題 / ${state.questions.length} 題`;
  elements.dimensionTag.textContent = question.dimensionLabel;
  elements.progressBar.style.width = `${((state.currentIndex + 1) / state.questions.length) * 100}%`;
  elements.questionText.textContent = question.text;
  elements.helperText.textContent = "請依照第一直覺選擇最符合自己的描述。";
  elements.prevButton.disabled = state.currentIndex === 0;

  elements.quizForm.innerHTML = "";
  state.answerScale.forEach((option, optionIndex) => {
    const optionNode = elements.optionTemplate.content.firstElementChild.cloneNode(true);
    const input = optionNode.querySelector("input");
    const title = optionNode.querySelector(".option-card__title");
    const subtitle = optionNode.querySelector(".option-card__subtitle");

    input.value = option.value;
    input.id = `question-${state.currentIndex}-option-${optionIndex}`;
    input.name = `question-${state.currentIndex}`;
    input.checked = currentAnswer === option.value;
    title.textContent = option.label;
    subtitle.textContent = option.description;
    input.addEventListener("change", handleAnswerSelection);

    optionNode.setAttribute("for", input.id);
    elements.quizForm.appendChild(optionNode);
  });
}

function handleAnswerSelection(event) {
  const selectedValue = Number(event.target.value);
  state.answers[state.currentIndex] = selectedValue;
  elements.helperText.textContent = "已記錄，準備進入下一題。";

  window.setTimeout(() => {
    if (state.currentIndex === state.questions.length - 1) {
      renderResult();
      return;
    }

    state.currentIndex += 1;
    renderQuestion();
  }, 140);
}

function getSelectedValue() {
  const checked = elements.quizForm.querySelector("input:checked");
  return checked ? Number(checked.value) : null;
}

function moveQuestion(direction) {
  if (direction === -1) {
    state.answers[state.currentIndex] = getSelectedValue();
  }

  state.currentIndex += direction;
  renderQuestion();
}

function calculateResult() {
  const totals = {
    EI: 0,
    SN: 0,
    TF: 0,
    JP: 0
  };

  state.questions.forEach((question, index) => {
    totals[question.dimension] += Number(state.answers[index] || 0);
  });

  const type = [
    totals.EI >= 0 ? "E" : "I",
    totals.SN >= 0 ? "S" : "N",
    totals.TF >= 0 ? "T" : "F",
    totals.JP >= 0 ? "J" : "P"
  ].join("");

  return { type, totals };
}

function renderDimensionGrid(totals) {
  const rows = [
    { key: "EI", positive: "E", negative: "I" },
    { key: "SN", positive: "S", negative: "N" },
    { key: "TF", positive: "T", negative: "F" },
    { key: "JP", positive: "J", negative: "P" }
  ];

  elements.dimensionGrid.innerHTML = "";
  rows.forEach((row) => {
    const score = totals[row.key];
    const letter = score >= 0 ? row.positive : row.negative;
    const pairLabels = dimensionLabels[row.key];
    const strength = Math.abs(score);
    const div = document.createElement("div");
    div.className = "dimension-item";
    div.innerHTML = `
      <strong>${letter}</strong>
      <span>${pairLabels[0]} / ${pairLabels[1]}</span><br>
      <span>偏好強度：${strength}</span>
    `;
    elements.dimensionGrid.appendChild(div);
  });
}

function renderList(target, items) {
  target.innerHTML = "";
  items.forEach((item) => {
    const li = document.createElement("li");
    li.textContent = item;
    target.appendChild(li);
  });
}

async function saveResult(type, totals) {
  elements.saveStatus.textContent = "結果儲存中...";

  try {
    const response = await fetch("/api/results", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        name: state.userName,
        type,
        totals,
        questionIds: state.questions.map((question) => question.id),
        answers: state.answers
      })
    });

    if (!response.ok) {
      let details = "";
      try {
        const payload = await response.json();
        details = payload.hint || payload.error || "";
      } catch (error) {
        details = response.statusText;
      }

      throw new Error(`Save failed (${response.status})${details ? `: ${details}` : ""}`);
    }

    elements.saveStatus.textContent = "結果已儲存。";
  } catch (error) {
    elements.saveStatus.textContent = "目前無法連線到後端，結果尚未儲存。";
    console.error("Result save failed:", error);
  }
}

function renderResult() {
  const { type, totals } = calculateResult();
  const result = state.mbtiTypes[type];

  elements.resultName.textContent = `${state.userName} 的測驗結果`;
  elements.resultType.textContent = type;
  elements.resultTitle.textContent = result.title;
  elements.resultSummary.textContent = result.summary;
  elements.roleReason.textContent = result.roleReason;
  elements.workstyleText.textContent = result.workstyle;
  elements.communicationText.textContent = result.communication;
  elements.stressText.textContent = result.stress;

  renderDimensionGrid(totals);
  renderList(elements.strengthsList, result.strengths);
  renderList(elements.challengesList, result.challenges);
  renderList(elements.rolesList, result.softwareRoles);

  showScreen("result");
  saveResult(type, totals);
}

function init() {
  try {
    loadData();
  } catch (error) {
    screens.intro.innerHTML = `
      <h2>資料載入失敗</h2>
      <p>請確認 data/questions.js 與 data/mbti-types.js 已正確載入。</p>
    `;
    console.error(error);
    return;
  }

  elements.startButton.addEventListener("click", startQuiz);
  elements.userNameInput.addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      startQuiz();
    }
  });
  elements.prevButton.addEventListener("click", () => moveQuestion(-1));
  elements.restartButton.addEventListener("click", () => {
    showScreen("intro");
    elements.userNameInput.focus();
  });
}

init();
