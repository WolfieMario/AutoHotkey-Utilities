/*
 *  Author: Gerrard Lukacs
 */

copySelected(cut=false, raw=false, restore=true)
{
    /* Retrieves selected text using Ctrl+C or Ctrl+X.
     * 
     * cut - If true, use Ctrl+X when retrieving text.
     * raw - If true, gets ClipboardAll instead of Clipboard.
     * restore - If true, restore the original contents of the clipboard after
     *           retrieving text.
     */
    
    if (restore)
        clipBackup := ClipboardAll
    
    Clipboard := "" ; Set to empty so ClipWait can wait for contents.
    if (cut)
        Send ^x
    else
        Send ^c
    ClipWait 1
    
    if (raw)
        result := ClipboardAll
    else
        result := Clipboard
    
    if (restore)
        Clipboard := clipBackup
    
    return result
}
