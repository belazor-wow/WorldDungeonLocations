local private = select(2, ...); ---@class PrivateNamespace

WDLMapLegendButtonMixin = CreateFromMixins(MapLegendButtonMixin)

function WDLMapLegendButtonMixin:InitializeButton(buttonInfo, index)
    self.Icon:SetTexture("Interface\\AddOns\\WorldDungeonLocations\\Textures\\dungeon-raid")
    self.Icon:SetSize(42, 42);

    if (buttonInfo.BackgroundAtlas) then
        self.IconBack:SetAtlas(buttonInfo.BackgroundAtlas, TextureKitConstants.UseAtlasSize);
        self.IconBack:Show();
    end
    self:SetText(buttonInfo.Text);
    self:Show();
    self.layoutIndex = index;
    self.tooltipText = buttonInfo.Tooltip;
    self.templates = buttonInfo.TemplateNames;
    --metadata
    self.metaData = buttonInfo.MetaData;

    EventRegistry:RegisterCallback("MapLegendPinOnEnter", self.HighlightSelfForPin, self);
    EventRegistry:RegisterCallback("MapLegendPinOnLeave", self.RemoveSelfHighlight, self);
end
