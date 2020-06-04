
/**
 *   Argumens for script:
 *   [0] - game path
 *   [1] - input file/folder under ${assets}/${quality}/
 *       if input is folder, then file with name skeleton.json will be converted and all inside dirrectories will be parsed as well
 *   [2] - converted file name (optional)
 *       if output is not specified, then output file name will be {inputName}-fixed.json
 */

var path = require('path')
var fs = require('fs')

//var resourcePath = path.resolve(path.join(__dirname, '..', '..', 'samples', 'assets'))
var convertQualities = ['low', 'high']
var convertParameters = ['x', 'y', 'pX', 'pY']

// slice starting from 2 because:
// 0 - node.exe
// 1 - scrip.js
var args = process.argv.slice(2);
var resourcePath = args[0]
var filePath = args[1]
var outName = args[2]

//console.log("args: ", args)

function parseObject(object, multiplier) {
    if (!object) return

    for (let [key, value] of Object.entries(object)) {
        
        if (typeof value === "object") {
            parseObject(value, multiplier)
        }
        else if (convertParameters.includes(key)) {
            object[key] = value *  multiplier
        }
    };
}

function parseFileContent(fullPath, multiplier) {

    console.log("Converting: ", fullPath)

    let fileContent = fs.readFileSync(fullPath, 'utf8')

    let jsonContent = null
    try {
        jsonContent = JSON.parse(fileContent)
    } catch(error) {
        console.error(error)
    }

    if (jsonContent) {

        parseObject(jsonContent, multiplier)

        let convertedPath = path.dirname(fullPath)
        if (outName) {
            convertedPath = path.join(convertedPath, outName)
        } else {
            convertedPath = path.join(convertedPath, path.basename(fullPath, '.json')) + "-fixed.json"
        }

        fs.writeFileSync(convertedPath, JSON.stringify(jsonContent), 'utf8')
    }
}

function parseFolders(folder, multiplier) {

    fs.readdirSync(folder).forEach(file => {
        let fullPath = path.join(folder, file)
        let stats = fs.statSync(fullPath)
        if (stats.isDirectory()) {
            parseFolders(fullPath, multiplier)
        } else if (path.extname(fullPath) === '.json')  {
            let baseName = path.basename(fullPath, '.json')
            if (baseName === "skeleton") {
                parseFileContent(fullPath, multiplier)
            }
        }
    })
}

function loadFiles() {

    convertQualities.forEach((quality) => {

        let fullPath = path.resolve(path.join(resourcePath, 'assets', quality, filePath))
        let multiplier = 1

        switch (quality) {
            case 'low':
                multiplier = 0.5
                break;
            case 'high':
                multiplier = 2.0
                break;
        }

        if (fs.existsSync(fullPath)) {
            let stats = fs.statSync(fullPath)
            if (stats.isDirectory()) {
                parseFolders(fullPath, multiplier)
            } else {
                parseFileContent(fullPath, multiplier)
            }

        } else {
            console.log("\'" + fullPath + "\' does not exist!");
        }
    })
}


loadFiles()