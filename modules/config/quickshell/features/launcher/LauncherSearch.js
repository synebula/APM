.pragma library
.import "FuzzySearch.js" as FuzzySearch

function getCount(history, entry) {
    if (!history || !entry) return 0;
    const key = entry.key || "";
    const label = entry.label || "";

    const candidates = [
        key,
        key.endsWith(".desktop") ? key.slice(0, -8) : (key ? key + ".desktop" : ""),
        label,
        label.endsWith(".desktop") ? label.slice(0, -8) : (label ? label + ".desktop" : "")
    ];

    for (const k of candidates) {
        if (!k) continue;
        const item = history[k];
        if (item !== undefined && item !== null) {
            return typeof item === "number" ? item : (item.count || 0);
        }
    }
    return 0;
}

function rank(entries, query, history) {
    const needle = FuzzySearch.normalized(query);
    const matches = [];
    for (const entry of entries) {
        const count = getCount(history, entry);
        let score = 0;
        if (needle) {
            score = Math.max.apply(null, entry.searchTerms.map(term => FuzzySearch.fuzzyScore(needle, term)));
            if (score < 0) continue;
            score += Math.min(500, count * 50);
        } else {
            score = count;
        }
        matches.push({ entry: entry, score: score });
    }
    matches.sort((left, right) => right.score - left.score || left.entry.label.localeCompare(right.entry.label));
    return matches.map(match => match.entry);
}
