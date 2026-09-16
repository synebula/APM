import QtQuick

QtObject {
    id: root

    required property string paletteId
    required property string displayName
    required property list<PaletteVariant> variants

    function variant(mode: string): PaletteVariant {
        return root.variants.find(variant => variant.variantId === mode) || null;
    }

    function accentIds(mode: string): var {
        const selected = root.variant(mode) || root.variants[0];
        return selected ? Object.keys(selected.accents) : [];
    }

    readonly property PaletteVariant defaultVariant: root.variant("light") || root.variants[0]
}
