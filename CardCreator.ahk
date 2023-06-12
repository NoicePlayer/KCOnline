#Include .\lib\JSON\JSON.ahk

; predetermined card dimensions
width := 175
height := 234

;#region create gui, including standard card accutrementes and saving buttons
template := Gui('-Border -SysMenu +Owner')

template.BackColor := 0x7900a8 ; purply
template.MarginX := width * 0.03
template.MarginY := height * 0.03

template.AddEdit('xm y+m W' width - 2 * template.MarginX ' Left vTitle +Border h' height * 0.1, '[NAME]').SetFont('bold')
template.AddPicture('W' width - 2 * template.MarginX ' h' height * 0.4 ' vImage', 'lib\imgs\zzimg_not_found.png')
template.AddEdit('y+0 W' width - 2 * template.MarginX ' h' height * 0.08 ' vType', '[TYPE]').SetFont(, 'Courier')
template.addEdit('W' width - 2 * template.MarginX ' h' height * 0.31 ' -VScroll vDesc', '[DESCRIPTION]')
template.AddEdit('y+0 W' width - 2 * template.MarginX ' h' height * 0.08 ' vLore Center -Border BackgroundWhite', '[LORE]').SetFont('italic')
template.AddButton('W' width * 0.455 ' h' height * 0.11 ' vSaveas Center +Border', 'Save as...').SetFont('bold', 'Comic Sans MS')
template.AddButton('yp X' width * 0.515 ' W' width * 0.455 ' h' height * 0.11 ' vSave Center +Border', 'Save...').SetFont('bold', 'Comic Sans MS')

template['Image'].OnEvent('click', getImage)
; getting ['Image'].value will not return updated image path :(
global img_value := template['Image'].Value

template['Save'].OnEvent('click', save)
template['Saveas'].OnEvent('click', saveAs.Bind(''))

template.Show()
;#endregion

; allow for previewing images on custom cards
getImage(*) {
    if (FileExist('.\lib\imgs')) {
        defaultDir := A_ScriptDir '\lib\imgs'
    } else {
        defaultDir := A_ScriptDir
    }
    f := FileSelect('3', defaultDir, 'Select an image...', 'Images (*.PNG;*.JPG;*.JPEG;*.GIF;*.BMP;*.ICO;*.CUR;*.ANI;*.TIF;*.Exif;*.WMF;*.EMF;)')

    if (FileExist(f)) {
        template['Image'].Value := f
        global img_value := f
    } else {
        MsgBox("Failed to load file", 'Image not found', 0x10)
    }
}

; allow the card to be saved to a JSON file
save(*) {
    global readCards, parentFile

    saveData := Map(template['Title'].Text, Map('id', Random(, 9999999), 'name', template['Title'].Text, 'image', img_value, 'desc', template['desc'].Text, 'lore', template['lore'].Text, 'type', template['Type'].Text, 'attrib', []))

    if (IsSet(readCards)) {
        for key, val in saveData {
            readCards.Set(key, val)
        }

        FileDelete(parentFile)
        FileAppend(JSON.stringify(readCards, 1), parentFile, 'UTF-8')
        MsgBox('Card saved successfully.')
    } else {
        select()
        if (parentFile)
            save()
    }
}

; saves card to new file/overwrites old file
saveAs(path := '', *) {
    saveData := Map(template['Title'].Text, Map('id', Random(, 9999999), 'name', template['Title'].Text, 'image', img_value, 'desc', template['desc'].Text, 'lore', template['lore'].Text, 'type', template['Type'].Text, 'attrib', []))
    
    if (!path)
        path := FileSelect('S16', A_ScriptDir '.\Custom Card.JSON', 'Save card as...', 'JSON File (*.JSON;*.txt)')

    if (FileExist(path))
        FileDelete(path)
    FileAppend(JSON.stringify(saveData, 1), path, 'UTF-8')

    global parentFile := path
    select(true)
}

; selects an exxisting JSON files of cards to read and append cards to
select(skip := false, *) {
    if (!skip)
        global parentFile := FileSelect('11', A_ScriptDir, 'Select JSON file...', 'JSON File (*.JSON;*.txt)')
    try {
        if (!parentFile)
            return

        global readCards := JSON.parse(FileRead(parentFile))
    } catch OSError {
        saveAs(parentFile)
    } catch as e
        MsgBox('Invalid JSON file.`n`n' e.Message, 'Error parsing JSON', 0x10)
}


#HotIf WinActive(A_ScriptName)
^BackSpace:: Send '^+{Left}{Ctrl Up}{Shift Up}{Delete}'