pragma Singleton
import "./palettes"
import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property list<PaletteDefinition> palettes: [
        Catppuccin {},
        PastelReliefPalette {},
        Everforest {},
        Nord {},
        TokyoNight {}
    ]
    readonly property PaletteDefinition defaultPalette: root.find("pastel-relief")

    function find(paletteId: string): PaletteDefinition {
        return root.palettes.find(palette => palette.paletteId === paletteId) || null;
    }

    function findVariant(paletteId: string, mode: string): PaletteVariant {
        const palette = root.find(paletteId);
        return palette ? palette.variant(mode) : null;
    }

    function variant(paletteId: string, mode: string): PaletteVariant {
        const found = root.findVariant(paletteId, mode);
        if (found)
            return found;
        const palette = root.find(paletteId) || root.defaultPalette;
        return palette ? (palette.variant(mode) || palette.defaultVariant) : null;
    }

    function accentIds(paletteVariant: PaletteVariant): var {
        return paletteVariant ? Object.keys(paletteVariant.accents) : [];
    }
}
