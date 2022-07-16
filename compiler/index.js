const { bundle } = require('luabundle');
const { writeFileSync } = require('fs');
const { ordinal } = require('./modules/ordinal');
const date = require('date-and-time');
const { gitToJs } = require('git-parse');
const { minify } = require('luamin');

const today = new Date()
var bundledLua = bundle('./corvette.lua', {
    metadata: false,
    luaVersion: "LuaJIT",
});

(async () => {
    const commits = await gitToJs('./');
    bundledLua = bundledLua.replace(/@[A-Z_]+?@/g, match => {
        const name = match.slice(1, -1)
        const values = {
            BUILD_DATE: () =>
                (date.format(today, 'HH:mm, MMMM ') + ordinal(today.getDate()) + ", " + today.getFullYear()).toLowerCase(),
            BUILD_VERSION: () => commits.length
        }
        if(values[name]){
            const value = values[name]()
            console.log(`${name}: ${value}`)
            return value
        }
    })
    bundledLua = minify(bundledLua)
    writeFileSync('./corvette-build.lua', bundledLua)
})()