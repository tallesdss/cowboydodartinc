"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const entity_utils_1 = require("../../../../core/data/entities/entity_utils");
describe("cleanStringForCompare", () => {
    it("should remove all multiple spaces, accents and -,_", () => {
        expect((0, entity_utils_1.cleanStringForCompare)("LANFEUST DES ÉTOILES")).toBe("lanfeust des etoiles");
        expect((0, entity_utils_1.cleanStringForCompare)("Lanfeust des étoiles")).toBe("lanfeust des etoiles");
        expect((0, entity_utils_1.cleanStringForCompare)("ùnià as THE fear-of-ça")).toBe("unia as the fear of ca");
    });
});
describe("cleanData", () => {
    it("should remove object null or undefined properties", () => {
        const input = { a: null, b: undefined, c: "c" };
        const output = (0, entity_utils_1.cleanData)(input);
        expect(output).toEqual({ c: "c" });
    });
    it("should not change input", () => {
        const input = { a: null, b: undefined, c: "c" };
        const output = (0, entity_utils_1.cleanData)(input);
        expect(output).not.toEqual(input);
    });
});
describe("cleanEntityId", () => {
    it("should remove object null or undefined properties", () => {
        const input = { a: null, b: undefined, c: "c" };
        const output = (0, entity_utils_1.cleanEntityId)(input);
        expect(output).toEqual({ c: "c" });
    });
    it("should remove object id", () => {
        const input = { id: "dsqdd", b: undefined, c: "c" };
        const output = (0, entity_utils_1.cleanEntityId)(input);
        expect(output).toEqual({ c: "c" });
    });
    it("should not change input", () => {
        const input = { a: null, b: undefined, c: "c" };
        const output = (0, entity_utils_1.cleanEntityId)(input);
        expect(output).not.toEqual(input);
    });
});
//# sourceMappingURL=entity_utils.spec.js.map