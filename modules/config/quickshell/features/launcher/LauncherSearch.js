.pragma library
.import "FuzzySearch.js" as FuzzySearch

function getCount(history, entry) {
    const usage = history && entry ? history[entry.key] : null;
    return usage ? (usage.count || 0) : 0;
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
