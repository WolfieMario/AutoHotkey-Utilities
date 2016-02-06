/*
 *  Author: Gerrard Lukacs
 */

/* This include script provides wrappers for some Gui-related commands,
 * a GuiWindow class for simpler creation/destruction of Gui windows where
 * results must be retrieved, and a namespace, GuiLayout, to help add,
 * position, and size controls.
 */

SysGet(subCommand, param3="")
{
    ; Function wrapper for SysGet command. Returns result.
    SysGet, result, %subCommand%, %param3%
    return result
}

GuiControlGet(guiName, controlID, subCommand="", param4="")
{
    ; Function wrapper for GuiControlGet command. Returns result.
    GuiControlGet, result, %guiName%:%subCommand%, %controlID%, %param4%
    return result
}


class GuiWindow
{
    ; A dictionary mapping from Gui names or HWNDs to GuiWindow instances.
    static guis := {}
    
    name := ""
    hwnd := 0
    id := 0
    
    buttonPressed := ""
    
    __New(title="", guiName="")
    {
        /* Create a new managed Gui with the given title and name, and make
         * it the default.
         * If a name is not given, this creates an anonymous Gui, and its id
         * becomes its hwnd. Otherwise, its id is its name. In either case,
         * the id can be used to specify this Gui in Gui commands.
         */
        this.name := guiName
        
        if (guiName = "")
        {
            Gui New, +LabelGuiWindow +LastFound +HwndHwnd, %title%
            guiName := hwnd
        }
        else
        {
            Gui %guiName%:New, +LabelGuiWindow +LastFound +HwndHwnd, %title%
        }
        Gui %guiName%:Default
        
        this.hwnd := hwnd
        this.id := guiName
        GuiWindow.guis[this.id] := this
    }
    
    dispose()
    {
        ; Destroy the managed Gui.
        
        guiId := this.id
        Gui %guiId%:Destroy
        
        if guiId is integer
            GuiWindow.guis.remove(guiId, "") ; Avoid shifting other int keys
        else
            GuiWindow.guis.remove(guiId)
    }
    
    __GuiWindowLabels()
    {
        return
        
        GuiWindowSubmit:
            GuiWindow.guis[A_Gui].buttonPressed := A_GuiControl
            Gui Submit
        Return
        
        GuiWindowClose:
        GuiWindowEscape:
            GuiWindow.guis[A_Gui].buttonPressed := false
            Gui Cancel
        Return
    }
    
}


class GuiLayout ; "namespace", do not instantiate.
{
    class Sizes
    {
        static WINDOW_BORDER_WIDTH := SysGet(32) ; SM_CXSIZEFRAME/SM_CXFRAME
        ; Title bar is a caption area with a border.
        static WINDOW_TITLE_HEIGHT := SysGet(4) ; SM_CYCAPTION
                                    + GuiLayout.Sizes.WINDOW_BORDER_WIDTH
        
        static MARGIN_HORIZONTAL := 10
        static PAD_HORIZONTAL := 6
        
        static BUTTON_WIDTH := 75
        static BUTTON_HEIGHT := 23
        
        getRowOffset(windowWidth, controlWidth, numControls=1)
        {
            ; Get the horizontal offset from the window margin needed to
            ; center a row of controls separated by PAD_HORIZONTAL.
            totalWidth := ((controlWidth + GuiLayout.Sizes.PAD_HORIZONTAL)
                           * numControls) - GuiLayout.Sizes.PAD_HORIZONTAL
            return round((windowWidth - totalWidth) / 2)
        }
    }
    
    addLabel(text, width, style="")
    {
        ; Add a centered label (Text) to the default Gui.
        style .= " W" . width . " Center"
        Gui Add, Text, %style%, %text%
    }
    
    addExitButtons(windowWidth, guiLabel="GuiWindow", okText="OK", cancelText="Cancel", style="")
    {
        ; Add submit and cancel buttons to the default Gui. If okText or
        ; cancelText is blank, the corresponding button is not added.
        ; guiLabel is a +Label prefix; the OK button is associated with the
        ; guiLabelSubmit label, while Cancel is associated with guiLabelClose.
        
        style .= " W" GuiLayout.Sizes.BUTTON_WIDTH " H" GuiLayout.Sizes.BUTTON_HEIGHT
        offset := "Default X" . GuiLayout.Sizes.getRowOffset(windowWidth
                , GuiLayout.Sizes.BUTTON_WIDTH, (okText && cancelText ? 2 : 1))
        
        if (okText)
        {
            Gui Add, Button, % style . " g" . guiLabel . "Submit " . offset, %okText%
            offset := "X+" . GuiLayout.Sizes.PAD_HORIZONTAL
        }
        if (cancelText)
            Gui Add, Button, % style . " g" . guiLabel . "Close " . offset, %cancelText%
    }
    
}
