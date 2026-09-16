.pragma library

function normalized(s) {
  return (s || "").toLowerCase();
}


function application(appId, title) {
  const c = normalized(appId);
  const t = normalized(title);

  // kitty special
  if (
    c.includes("kitty") &&
    (t.includes("claude") || t.includes("✳") || t.includes("✦"))
  )
    return "✳";
  if (c.includes("kitty") && t.includes("codex")) return "";

  // common
  if (t.includes("youtube")) return "";
  if (t.includes("obsidian")) return "";
  if (c.includes("fcitx")) return "󰌌";
  if (c.includes("cursor")) return "󰅪";
  if (c.includes("jetbrains") || c.includes("idea")) return "";
  if (c.includes("dbeaver")) return "";
  if (c.includes("antigravity")) return "󰲇";
  if (
    c === "code" ||
    c === "code-url-handler" ||
    c === "code-oss" ||
    c === "code-oss-dev"
  )
    return "󰨞";
  if (c.includes("microsoft-edge") || c === "msedge") return "";
  if (
    c.includes("chromium") ||
    (c.includes("chrome") && !c.includes("chromedriver"))
  )
    return "";
  if (c.includes("cherrystudio") || c.includes("cherry-studio")) return "";
  if (c.includes("orca")) return "󰹛";
  if (c.includes("herdr")) return "󰳆";
  if (c.includes("kitty")) return "";
  if (c.includes("nemo")) return "󰪶";
  if (c.includes("nautilus")) return "";
  if (c.includes("wechat") || c.includes("weixin")) return "";
  if (c === "et") return "󰈛";
  if (c.includes("wps")) return "󰈬";
  if (c.includes("vlc")) return "󰕼";
  return "";
}

function volume(muted, volume) {
  if (muted) return "󰝟";
  const pct = Math.round((volume || 0) * 100);
  if (pct < 30) return "";
  if (pct < 70) return "";
  return "";
}

function temperature(c) {
  if (c < 40) return "";
  if (c < 50) return "";
  if (c < 65) return "";
  if (c < 80) return "";
  return "";
}
