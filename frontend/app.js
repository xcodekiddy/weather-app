const GEOCODE_URL = "https://geocoding-api.open-meteo.com/v1/search";
const FORECAST_URL = "https://api.open-meteo.com/v1/forecast";

const ICON_BASE = "https://cdn.jsdelivr.net/gh/basmilius/weather-icons@dev/production/fill/svg";

const WEATHER_CODES = {
  0:  { label: "Clear sky",              iconDay: "clear-day",              iconNight: "clear-night",              theme: "" },
  1:  { label: "Mainly clear",           iconDay: "partly-cloudy-day",      iconNight: "partly-cloudy-night",      theme: "" },
  2:  { label: "Partly cloudy",          iconDay: "partly-cloudy-day",      iconNight: "partly-cloudy-night",      theme: "cloud" },
  3:  { label: "Overcast",               iconDay: "overcast-day",           iconNight: "overcast-night",           theme: "cloud" },
  45: { label: "Fog",                    iconDay: "fog-day",                iconNight: "fog-night",                theme: "cloud" },
  48: { label: "Depositing rime fog",    iconDay: "fog-day",                iconNight: "fog-night",                theme: "cloud" },
  51: { label: "Light drizzle",          iconDay: "drizzle",                iconNight: "drizzle",                  theme: "rain" },
  53: { label: "Moderate drizzle",       iconDay: "drizzle",                iconNight: "drizzle",                  theme: "rain" },
  55: { label: "Dense drizzle",          iconDay: "extreme-drizzle",        iconNight: "extreme-drizzle",          theme: "rain" },
  56: { label: "Freezing drizzle",       iconDay: "sleet",                  iconNight: "sleet",                    theme: "rain" },
  57: { label: "Dense freezing drizzle", iconDay: "extreme-sleet",          iconNight: "extreme-sleet",            theme: "rain" },
  61: { label: "Light rain",             iconDay: "partly-cloudy-day-rain", iconNight: "partly-cloudy-night-rain", theme: "rain" },
  63: { label: "Rain",                   iconDay: "rain",                   iconNight: "rain",                     theme: "rain" },
  65: { label: "Heavy rain",             iconDay: "extreme-rain",           iconNight: "extreme-rain",             theme: "rain" },
  66: { label: "Freezing rain",          iconDay: "sleet",                  iconNight: "sleet",                    theme: "rain" },
  67: { label: "Heavy freezing rain",    iconDay: "extreme-sleet",          iconNight: "extreme-sleet",            theme: "rain" },
  71: { label: "Light snow",             iconDay: "partly-cloudy-day-snow", iconNight: "partly-cloudy-night-snow", theme: "snow" },
  73: { label: "Snow",                   iconDay: "snow",                   iconNight: "snow",                     theme: "snow" },
  75: { label: "Heavy snow",             iconDay: "extreme-snow",           iconNight: "extreme-snow",             theme: "snow" },
  77: { label: "Snow grains",            iconDay: "snow",                   iconNight: "snow",                     theme: "snow" },
  80: { label: "Rain showers",           iconDay: "partly-cloudy-day-rain", iconNight: "partly-cloudy-night-rain", theme: "rain" },
  81: { label: "Heavy showers",          iconDay: "rain",                   iconNight: "rain",                     theme: "rain" },
  82: { label: "Violent showers",        iconDay: "extreme-rain",           iconNight: "extreme-rain",             theme: "storm" },
  85: { label: "Snow showers",           iconDay: "partly-cloudy-day-snow", iconNight: "partly-cloudy-night-snow", theme: "snow" },
  86: { label: "Heavy snow showers",     iconDay: "extreme-snow",           iconNight: "extreme-snow",             theme: "snow" },
  95: { label: "Thunderstorm",           iconDay: "thunderstorms-day",      iconNight: "thunderstorms-night",      theme: "storm" },
  96: { label: "Thunderstorm w/ hail",   iconDay: "thunderstorms-day-rain", iconNight: "thunderstorms-night-rain", theme: "storm" },
  99: { label: "Severe thunderstorm",    iconDay: "thunderstorms-day-rain", iconNight: "thunderstorms-night-rain", theme: "storm" },
};

function iconUrl(code, isDay) {
  const d = WEATHER_CODES[code] ?? WEATHER_CODES[0];
  const name = isDay ? d.iconDay : d.iconNight;
  return `${ICON_BASE}/${name}.svg`;
}

function weatherImg(code, isDay, size) {
  const d = WEATHER_CODES[code] ?? WEATHER_CODES[0];
  return `<img src="${iconUrl(code, isDay)}" alt="${d.label}" width="${size}" height="${size}" loading="lazy">`;
}

const els = {
  form: document.getElementById("search-form"),
  input: document.getElementById("search-input"),
  locateBtn: document.getElementById("locate-btn"),
  suggestions: document.getElementById("suggestions"),
  unitToggle: document.querySelector(".unit-toggle"),
  status: document.getElementById("status"),
  current: document.getElementById("current"),
  hourly: document.getElementById("hourly"),
  hourlyList: document.getElementById("hourly-list"),
  forecast: document.getElementById("forecast"),
  forecastList: document.getElementById("forecast-list"),
  location: document.getElementById("location"),
  localTime: document.getElementById("local-time"),
  icon: document.getElementById("icon"),
  temp: document.getElementById("temp"),
  condition: document.getElementById("condition"),
  feels: document.getElementById("feels"),
  humidity: document.getElementById("humidity"),
  wind: document.getElementById("wind"),
  precip: document.getElementById("precip"),
};

const state = {
  unit: localStorage.getItem("unit") === "c" ? "c" : "f",
  refresh: null,
};

function setStatus(msg, isError = false) {
  els.status.textContent = msg || "";
  els.status.classList.toggle("error", !!isError);
}

function describe(code) {
  return WEATHER_CODES[code] ?? { label: "Unknown", iconDay: "clear-day", iconNight: "clear-night", theme: "" };
}

function setTheme(code, isDay) {
  const d = describe(code);
  document.body.classList.remove("theme-night", "theme-cloud", "theme-rain", "theme-snow", "theme-storm");
  if (!isDay) document.body.classList.add("theme-night");
  else if (d.theme) document.body.classList.add(`theme-${d.theme}`);
}

function formatWind(speed, dir) {
  const dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
  const idx = Math.round(((dir % 360) / 45)) % 8;
  const unit = state.unit === "c" ? "km/h" : "mph";
  return `${Math.round(speed)} ${unit} ${dirs[idx]}`;
}

function formatDay(dateStr, idx) {
  if (idx === 0) return "Today";
  const d = new Date(dateStr + "T00:00:00");
  return d.toLocaleDateString(undefined, { weekday: "short" });
}

function formatHour(dateStr, isNow) {
  if (isNow) return "Now";
  const d = new Date(dateStr);
  return d.toLocaleTimeString(undefined, { hour: "numeric" });
}

async function geocode(query) {
  const url = `${GEOCODE_URL}?name=${encodeURIComponent(query)}&count=1&language=en&format=json`;
  const res = await fetch(url);
  if (!res.ok) throw new Error("Could not reach geocoding service.");
  const data = await res.json();
  if (!data.results || data.results.length === 0) {
    throw new Error(`No match for "${query}".`);
  }
  return data.results[0];
}

async function fetchWeather(lat, lon) {
  const isC = state.unit === "c";
  const params = new URLSearchParams({
    latitude: lat,
    longitude: lon,
    current: "temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m,wind_direction_10m",
    hourly: "temperature_2m,weather_code,is_day",
    daily: "weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum",
    temperature_unit: isC ? "celsius" : "fahrenheit",
    wind_speed_unit: isC ? "kmh" : "mph",
    precipitation_unit: isC ? "mm" : "inch",
    timezone: "auto",
    forecast_days: "7",
  });
  const res = await fetch(`${FORECAST_URL}?${params}`);
  if (!res.ok) throw new Error("Could not fetch weather.");
  return res.json();
}

function renderCurrent(place, data) {
  const c = data.current;
  const d = describe(c.weather_code);
  const name = [place.name, place.admin1, place.country].filter(Boolean).join(", ");
  els.location.textContent = name;
  const now = new Date(c.time);
  els.localTime.textContent = now.toLocaleString(undefined, {
    weekday: "long",
    hour: "numeric",
    minute: "2-digit",
  });
  els.icon.innerHTML = weatherImg(c.weather_code, c.is_day, 80);
  els.temp.textContent = Math.round(c.temperature_2m);
  els.condition.textContent = d.label;
  els.feels.textContent = `${Math.round(c.apparent_temperature)}°`;
  els.humidity.textContent = `${c.relative_humidity_2m}%`;
  els.wind.textContent = formatWind(c.wind_speed_10m, c.wind_direction_10m);
  const precipUnit = state.unit === "c" ? "mm" : "in";
  els.precip.textContent = `${c.precipitation} ${precipUnit}`;
  setTheme(c.weather_code, c.is_day);
  els.current.hidden = false;
}

function renderHourly(data) {
  const h = data.hourly;
  const nowTime = new Date(data.current.time).getTime();
  let startIdx = h.time.findIndex((t) => new Date(t).getTime() >= nowTime);
  if (startIdx < 0) startIdx = 0;
  const end = Math.min(startIdx + 24, h.time.length);

  const items = [];
  for (let i = startIdx; i < end; i++) {
    const d = describe(h.weather_code[i]);
    const isNow = i === startIdx;
    items.push(`
      <li class="${isNow ? "now" : ""}" style="--i:${i - startIdx}">
        <span class="h-time">${formatHour(h.time[i], isNow)}</span>
        <span class="h-icon">${weatherImg(h.weather_code[i], h.is_day[i], 28)}</span>
        <span class="h-temp">${Math.round(h.temperature_2m[i])}°</span>
      </li>
    `);
  }
  els.hourlyList.innerHTML = items.join("");
  els.hourly.hidden = false;
}

function renderForecast(data) {
  const days = data.daily;
  const lows = days.temperature_2m_min;
  const highs = days.temperature_2m_max;
  const globalMin = Math.min(...lows);
  const globalMax = Math.max(...highs);
  const span = Math.max(1, globalMax - globalMin);

  els.forecastList.innerHTML = "";
  days.time.forEach((date, i) => {
    const d = describe(days.weather_code[i]);
    const hi = highs[i];
    const lo = lows[i];
    const left = ((lo - globalMin) / span) * 100;
    const width = ((hi - lo) / span) * 100;

    const li = document.createElement("li");
    li.style.setProperty("--i", i);
    li.innerHTML = `
      <span class="day">${formatDay(date, i)}</span>
      <span class="fi">${weatherImg(days.weather_code[i], true, 30)}</span>
      <span class="bar"><span class="fill" style="left:${left}%;width:${width}%"></span></span>
      <span class="range">
        <span class="lo">${Math.round(lo)}°</span>
        <span class="hi">${Math.round(hi)}°</span>
      </span>
    `;
    els.forecastList.appendChild(li);
  });
  els.forecast.hidden = false;
}

async function loadAndRender(coords, placeLabel) {
  setStatus("Loading weather…");
  const hasContent = !els.current.hidden;
  if (hasContent) document.body.classList.add("is-updating");
  try {
    const data = await fetchWeather(coords.latitude, coords.longitude);
    renderCurrent(placeLabel, data);
    renderHourly(data);
    renderForecast(data);
    setStatus("");
    if (hasContent) {
      requestAnimationFrame(() => {
        document.body.classList.remove("is-updating");
      });
    }
    els.temp.classList.remove("flash");
    void els.temp.offsetWidth;
    els.temp.classList.add("flash");
  } catch (err) {
    document.body.classList.remove("is-updating");
    setStatus(err.message, true);
  }
}

async function showWeatherFor(query) {
  setStatus("Searching…");
  try {
    const place = await geocode(query);
    state.refresh = () => loadAndRender(place, place);
    await loadAndRender(place, place);
  } catch (err) {
    setStatus(err.message, true);
  }
}

async function showWeatherForCoords(lat, lon, label) {
  const placeLabel = { name: label, admin1: "", country: "" };
  const coords = { latitude: lat, longitude: lon };
  state.refresh = () => loadAndRender(coords, placeLabel);
  await loadAndRender(coords, placeLabel);
}

// IP-based geolocation — no permission prompt required. We try several
// public providers in order because any one of them can be rate-limited,
// blocked by the user's network, or temporarily down.
const IP_LOCATION_PROVIDERS = [
  {
    name: "ipwho.is",
    url: "https://ipwho.is/",
    parse: (d) => {
      if (d.success === false) throw new Error(d.message || "lookup failed");
      return { lat: d.latitude, lon: d.longitude, city: d.city, region: d.region };
    },
  },
  {
    name: "ipapi.co",
    url: "https://ipapi.co/json/",
    parse: (d) => {
      if (d.error) throw new Error(d.reason || "lookup failed");
      return { lat: d.latitude, lon: d.longitude, city: d.city, region: d.region };
    },
  },
  {
    name: "freeipapi.com",
    url: "https://freeipapi.com/api/json",
    parse: (d) => ({
      lat: d.latitude,
      lon: d.longitude,
      city: d.cityName,
      region: d.regionName,
    }),
  },
];

async function fetchIpLocation() {
  const errors = [];
  for (const p of IP_LOCATION_PROVIDERS) {
    try {
      const res = await fetch(p.url, { cache: "no-store" });
      if (!res.ok) throw new Error("HTTP " + res.status);
      const data = await res.json();
      const { lat, lon, city, region } = p.parse(data);
      if (typeof lat !== "number" || typeof lon !== "number") {
        throw new Error("no coordinates in response");
      }
      const label = city
        ? `${city}${region ? ", " + region : ""}`
        : "Your location";
      return { latitude: lat, longitude: lon, label };
    } catch (err) {
      errors.push(`${p.name}: ${err.message}`);
    }
  }
  throw new Error(errors.join(" | ") || "all providers failed");
}

async function useCurrentLocation() {
  els.locateBtn.classList.add("loading");
  els.locateBtn.disabled = true;
  setStatus("Getting your location…");
  try {
    const { latitude, longitude, label } = await fetchIpLocation();
    els.input.value = "";
    localStorage.removeItem("last-city");
    localStorage.setItem("use-location", "1");
    await showWeatherForCoords(latitude, longitude, label);
  } catch (err) {
    console.error("IP location failed:", err);
    setStatus(`Couldn't determine your location (${err.message}). Try searching for a city.`, true);
  } finally {
    els.locateBtn.classList.remove("loading");
    els.locateBtn.disabled = false;
  }
}

function applyUnitUI() {
  els.unitToggle.dataset.active = state.unit;
  els.unitToggle.querySelectorAll("button").forEach((b) => {
    b.classList.toggle("active", b.dataset.unit === state.unit);
  });
}

function setUnit(u) {
  if (state.unit === u) return;
  state.unit = u;
  localStorage.setItem("unit", u);
  applyUnitUI();
  if (state.refresh) state.refresh();
}

els.unitToggle.addEventListener("click", (e) => {
  const btn = e.target.closest("button[data-unit]");
  if (btn) setUnit(btn.dataset.unit);
});

els.form.addEventListener("submit", (e) => {
  e.preventDefault();
  if (suggestionIdx >= 0 && suggestionList[suggestionIdx]) {
    selectSuggestion(suggestionIdx);
    return;
  }
  const q = els.input.value.trim();
  if (!q) return;
  localStorage.setItem("last-city", q);
  localStorage.removeItem("use-location");
  hideSuggestions();
  showWeatherFor(q);
});

els.locateBtn.addEventListener("click", useCurrentLocation);

/* ---------- Autocomplete suggestions ---------- */

let suggestionList = [];
let suggestionIdx = -1;
let suggestionTimer = null;
let suggestionAbort = null;

function showSuggestionsVisible(on) {
  els.suggestions.hidden = !on;
  els.input.setAttribute("aria-expanded", on ? "true" : "false");
}

function hideSuggestions() {
  showSuggestionsVisible(false);
  suggestionList = [];
  suggestionIdx = -1;
}

function updateActiveSuggestion() {
  const items = els.suggestions.querySelectorAll("li");
  items.forEach((li, i) => li.classList.toggle("active", i === suggestionIdx));
  if (suggestionIdx >= 0 && items[suggestionIdx]) {
    items[suggestionIdx].scrollIntoView({ block: "nearest" });
  }
}

function renderSuggestions(results) {
  suggestionList = results;
  suggestionIdx = -1;
  const pinSvg = `<svg class="pin" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>`;
  els.suggestions.innerHTML = results.map((r, i) => {
    const region = [r.admin1, r.country].filter(Boolean).join(", ");
    return `<li role="option" data-idx="${i}">
      ${pinSvg}
      <span class="labels">
        <span class="city">${escapeHtml(r.name)}</span>
        <span class="region">${escapeHtml(region)}</span>
      </span>
    </li>`;
  }).join("");
  showSuggestionsVisible(true);
}

function escapeHtml(s) {
  return String(s).replace(/[&<>"']/g, (c) => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"
  }[c]));
}

async function fetchSuggestions(query) {
  if (suggestionAbort) suggestionAbort.abort();
  suggestionAbort = new AbortController();
  try {
    const url = `${GEOCODE_URL}?name=${encodeURIComponent(query)}&count=6&language=en&format=json`;
    const res = await fetch(url, { signal: suggestionAbort.signal });
    if (!res.ok) return hideSuggestions();
    const data = await res.json();
    if (!data.results || data.results.length === 0) return hideSuggestions();
    renderSuggestions(data.results);
  } catch (err) {
    if (err.name !== "AbortError") hideSuggestions();
  }
}

function selectSuggestion(idx) {
  const place = suggestionList[idx];
  if (!place) return;
  els.input.value = place.name;
  localStorage.setItem("last-city", place.name);
  localStorage.removeItem("use-location");
  hideSuggestions();
  state.refresh = () => loadAndRender(place, place);
  loadAndRender(place, place);
}

els.input.addEventListener("input", () => {
  const q = els.input.value.trim();
  clearTimeout(suggestionTimer);
  if (q.length < 2) {
    hideSuggestions();
    return;
  }
  suggestionTimer = setTimeout(() => fetchSuggestions(q), 180);
});

els.input.addEventListener("focus", () => {
  if (suggestionList.length > 0) showSuggestionsVisible(true);
});

els.input.addEventListener("keydown", (e) => {
  if (els.suggestions.hidden || suggestionList.length === 0) return;
  if (e.key === "ArrowDown") {
    e.preventDefault();
    suggestionIdx = (suggestionIdx + 1) % suggestionList.length;
    updateActiveSuggestion();
  } else if (e.key === "ArrowUp") {
    e.preventDefault();
    suggestionIdx = suggestionIdx <= 0 ? suggestionList.length - 1 : suggestionIdx - 1;
    updateActiveSuggestion();
  } else if (e.key === "Escape") {
    hideSuggestions();
  }
});

els.suggestions.addEventListener("mousedown", (e) => {
  const li = e.target.closest("li[data-idx]");
  if (!li) return;
  e.preventDefault();
  selectSuggestion(Number(li.dataset.idx));
});

els.suggestions.addEventListener("mousemove", (e) => {
  const li = e.target.closest("li[data-idx]");
  if (!li) return;
  suggestionIdx = Number(li.dataset.idx);
  updateActiveSuggestion();
});

document.addEventListener("click", (e) => {
  if (!e.target.closest(".search-wrap")) hideSuggestions();
});

function setupPlatformClass() {
  const isMac = /Mac OS|Macintosh/i.test(navigator.userAgent) || (navigator.platform || "").startsWith("Mac");
  if (isMac) {
    document.body.classList.add("is-mac");
    return;
  }
  // On Windows/Linux, strip every data-tauri-drag-region attribute so the
  // runtime never attaches a drag handler and WebView2 never sees the
  // region as a non-client title bar. This is what actually blocks scroll.
  document.querySelectorAll("[data-tauri-drag-region]").forEach((el) => {
    el.removeAttribute("data-tauri-drag-region");
    el.style.setProperty("-webkit-app-region", "no-drag", "important");
    el.style.setProperty("app-region", "no-drag", "important");
  });
}

function setupExternalLinks() {
  const openExternal = (url) => {
    const opener = window.__TAURI__?.opener?.openUrl;
    if (opener) {
      opener(url).catch((err) => console.error("Failed to open URL", err));
    } else {
      window.open(url, "_blank", "noopener");
    }
  };
  document.addEventListener("click", (e) => {
    const a = e.target.closest('a[href^="http"]');
    if (!a) return;
    e.preventDefault();
    openExternal(a.href);
  });
}

function setupWindowDrag() {
  // Only on macOS (no native title bar). On Windows/Linux this interferes
  // with scrolling and is unnecessary since the native title bar handles drags.
  if (!document.body.classList.contains("is-mac")) return;
  const dragRegion = document.querySelector("[data-window-drag]");
  const getCurrentWindow = window.__TAURI__?.window?.getCurrentWindow;
  if (!dragRegion || !getCurrentWindow) return;

  const appWindow = getCurrentWindow();
  dragRegion.addEventListener("mousedown", (e) => {
    if (e.button !== 0 || e.target.closest("[data-no-drag], button, input, a")) return;
    appWindow.startDragging().catch(() => {});
  });
}

function init() {
  setupPlatformClass();
  setupWindowDrag();
  setupExternalLinks();
  applyUnitUI();
  if (localStorage.getItem("use-location") === "1") {
    useCurrentLocation();
    return;
  }
  const saved = localStorage.getItem("last-city");
  if (saved) {
    els.input.value = saved;
    showWeatherFor(saved);
    return;
  }
  setStatus("Getting your location…");
  fetchIpLocation()
    .then(({ latitude, longitude, label }) =>
      showWeatherForCoords(latitude, longitude, label)
    )
    .catch(() => {
      setStatus("");
      showWeatherFor("San Francisco");
    });
}

init();
