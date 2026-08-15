"use strict";
/* eslint no-useless-escape: 0 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.escapeSpecialChars = exports.cleanStringForCompare = exports.cleanData = exports.cleanEntityId = void 0;
exports.hashCode = hashCode;
/**
 * Remove null and undefined properties from an object
 * and remove the id property as firebase stores it as a key
 * @param entity
 * @returns
 */
const cleanEntityId = (entity) => {
    const cleanedData = (0, exports.cleanData)(entity);
    if (cleanedData.id) {
        delete cleanedData["id"];
    }
    return cleanedData;
};
exports.cleanEntityId = cleanEntityId;
/**
 * Remove null and undefined properties from an object
 * @param res
 * @return  a copy of the object without null and undefined properties
 */
const cleanData = (res) => {
    const resCopy = Object.assign({}, res);
    const propNames = Object.getOwnPropertyNames(resCopy);
    for (let i = 0; i < propNames.length; i++) {
        const propName = propNames[i];
        if (res[propName] === null || res[propName] === undefined) {
            delete resCopy[propName];
        }
    }
    return resCopy;
};
exports.cleanData = cleanData;
function hashCode(str) {
    let h = 0;
    for (let i = 0; i < str.length; i++) {
        h = 31 * h + str.charCodeAt(i);
    }
    return h & 0xFFFFFFFF;
}
const cleanStringForCompare = (str) => {
    let result = str;
    result = result.toLowerCase();
    result = result.replace(/[àáâãäå]/g, "a");
    result = result.replace(/[èéêë]/g, "e");
    result = result.replace(/[ìíîï]/g, "i");
    result = result.replace(/[òóôõö]/g, "o");
    result = result.replace(/[ùúûü]/g, "u");
    result = result.replace(/[ýÿ]/g, "y");
    result = result.replace(/[ñ]/g, "n");
    result = result.replace(/[ç]/g, "c");
    result = result.replace(/[ß]/g, "ss");
    result = result.replace(/[œ]/g, "oe");
    result = result.replace(/[æ]/g, "ae");
    result = result.replace(/[\-_]/g, " ");
    result = result.replace(/(\s){2,}/g, " ");
    result = result.trim();
    return result;
};
exports.cleanStringForCompare = cleanStringForCompare;
const escapeSpecialChars = (str) => {
    let result = str;
    result = result.replace(/[\?]/g, "\\?");
    result = result.replace(/[\!]/g, "\\!");
    result = result.replace(/[\&]/g, "\\&");
    result = result.replace(/\(/g, "\\(");
    result = result.replace(/\)/g, "\\)");
    result = result.replace(/[\[]/g, "\\[");
    result = result.replace(/[\]]/g, "\\]");
    result = result.replace(/[\{]/g, "\\{");
    result = result.replace(/[\}]/g, "\\}");
    result = result.replace(/[\/]/g, "\\/");
    result = result.replace(/[\+]/g, "\\+");
    result = result.replace(/[\*]/g, "\\*");
    result = result.replace(/[\^]/g, "\\^");
    result = result.replace(/[\$]/g, "\\$");
    result = result.replace(/[\|]/g, "\\|");
    result = result.replace(/[\=]/g, "\\=");
    result = result.replace(/[\,]/g, "\\,");
    result = result.replace(/[\:]/g, "\\:");
    result = result.replace(/[\~]/g, "\\~");
    result = result.replace(/[\"]/g, "\\\"");
    result = result.replace(/[\.]/g, "\\.");
    result = result.replace(/[\']/g, "\\'");
    return result;
};
exports.escapeSpecialChars = escapeSpecialChars;
//# sourceMappingURL=entity_utils.js.map