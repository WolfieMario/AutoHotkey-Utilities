/*
 *  Author: Gerrard Lukacs
 */

#Include %A_LineFile%/../GuiHelper.ahk

inputMultiLine(title, message, numLines=7, monospace=false, width=600
             , okText="OK", cancelText="Cancel")
{
    /* Shows a multiple-line text input box, and returns the input text when
     * the user closes the window. If the user cancels, false is returned.
     * 
     * title - The title of the window.
     * message - A label at the top of the window. Omitted if empty.
     * numLines - The height of the text box, in lines.
     * monospace - If true, use Courier New for the text box.
     * width - Width, in pixels, of the text box and message.
     * okText - Text for the OK/Confirm/Submit button.
     * cancelText - Text for the Cancel/Abort button.
     */ 
    static inputText := ""
    
    window := new GuiWindow(title)
    
    if (message)
        GuiLayout.addLabel(message, width)
    if (monospace)
        Gui Font, , Courier New
    Gui Add, Edit, % "VinputText r" . numLines . " W" . width
    Gui Font ; Reset font before adding exit buttons
    GuiLayout.addExitButtons(width + GuiLayout.Sizes.MARGIN_HORIZONTAL * 2
                            , , okText, cancelText)
    
    Gui Show
    WinWaitClose % "ahk_id " . window.hwnd
    
    window.dispose()
    if (window.buttonPressed)
        return inputText
    else
        return false
}
