UITagModal = ISPanel:derive("UITagModal");

local DEFAULT_FONT = UIFont.Small;
local BUTTON_ADD_ID = 'ADD';
local BUTTON_REMOVE_ID = 'REMOVE';
local BUTTON_CANCEL_ID = 'CANCEL';

function UITagModal:initialise()
    ISPanel.initialise(self);

    local fontHgt = getTextManager():getFontFromEnum(DEFAULT_FONT):getLineHeight();
    local buttonAddW = getTextManager():MeasureStringX(DEFAULT_FONT, "Add") + 12;
    local buttonRemW = getTextManager():MeasureStringX(DEFAULT_FONT, "Remove") + 12;
    local buttonCancelW = getTextManager():MeasureStringX(DEFAULT_FONT, "Cancel") + 12;

    local buttonHgt = fontHgt + 6
    local padding = 5;

    local totalWidth = buttonAddW + padding + buttonRemW + padding + buttonCancelW;

    -- Create button for adding
    local posX = self:getWidth() * 0.5 - totalWidth * 0.5;
    self.add = ISButton:new(posX, self:getHeight() - 12 - buttonHgt, buttonAddW, buttonHgt, 'Add', self, UITagModal.onClick);
    self.add.internal = BUTTON_ADD_ID;
    self.add:initialise();
    self.add:instantiate();
    self.add.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.add);

    -- Create button for removal
    posX = posX + buttonAddW + padding;
    self.rem = ISButton:new(posX, self:getHeight() - 12 - buttonHgt, buttonRemW, buttonHgt, 'Remove', self, UITagModal.onClick);
    self.rem.internal = BUTTON_REMOVE_ID;
    self.rem:initialise();
    self.rem:instantiate();
    self.rem.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.rem);

    -- Create button for aborting
    posX = posX + buttonRemW + padding;
    self.cancel = ISButton:new(posX, self:getHeight() - 12 - buttonHgt, buttonCancelW, buttonHgt, 'Cancel', self, UITagModal.onClick);
    self.cancel.internal = BUTTON_CANCEL_ID;
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.cancel);

    self.fontHgt = getTextManager():getFontFromEnum(DEFAULT_FONT):getLineHeight()
    local inset = 2
    local height = inset + self.fontHgt + inset
    self.entry = ISTextEntryBox:new(self.defaultEntryText, self:getWidth() / 2 - ((self:getWidth() - 40) / 2), (self:getHeight() - height) / 2, self:getWidth() - 40, height);
    self.entry:initialise();
    self.entry:instantiate();
    self:addChild(self.entry);
end

function UITagModal:setOnlyNumbers(onlyNumbers)
    self.entry:setOnlyNumbers(onlyNumbers);
end

function UITagModal:destroy()
    UIManager.setShowPausedMessage(true);
    self:setVisible(false);
    self:removeFromUIManager();
    if UIManager.getSpeedControls() then
        UIManager.getSpeedControls():SetCurrentGameSpeed(1);
    end
end

function UITagModal:onClick(button)
    self:destroy();
    if self.onclick then
        self.onclick(self.target, button, self.player);
    end
end

function UITagModal:prerender()
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawTextCentre(self.text, self:getWidth() / 2, (self:getHeight() / 2) - 40, 1, 1, 1, 1, DEFAULT_FONT);
end

function UITagModal:render()
    return;
end

function UITagModal:new(x, y, width, height, text, target, onclick, player)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;

    -- TODO rewrite
    local playerObj = player and getSpecificPlayer(player) or nil
    if y == 0 then
        if playerObj and playerObj:getJoypadBind() ~= -1 then
            o.y = getPlayerScreenTop(player) + (getPlayerScreenHeight(player) - height) / 2
        else
            o.y = o:getMouseY() - (height / 2)
        end
        o:setY(o.y)
    end
    if x == 0 then
        if playerObj and playerObj:getJoypadBind() ~= -1 then
            o.x = getPlayerScreenLeft(player) + (getPlayerScreenWidth(player) - width) / 2
        else
            o.x = o:getMouseX() - (width / 2)
        end
        o:setX(o.x)
    end

    o.backgroundColor = { r = 0.0, g = 0.0, b = 0.0, a = 0.5 };
    o.borderColor     = { r = 0.4, g = 0.4, b = 0.4, a = 1.0 };

    local txtWidth = getTextManager():MeasureStringX(DEFAULT_FONT, text) + 10;
    o.width = width < txtWidth and txtWidth or width;
    o.height = height;

    o.anchorLeft = true;
    o.anchorRight = true;
    o.anchorTop = true;
    o.anchorBottom = true;

    o.text = text;
    o.target = target;
    o.onclick = onclick;
    o.player = player;
    o.defaultEntryText = '';
    return o;
end
