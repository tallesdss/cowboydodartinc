"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.promoteToAdmin = exports.onCommentWritten = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
/**
 * Recalcula a nota média e total de avaliações de um PDF sempre que um comentário é criado, editado ou excluído.
 */
exports.onCommentWritten = (0, firestore_1.onDocumentWritten)("comments/{commentId}", async (event) => {
    var _a, _b;
    const db = admin.firestore();
    const beforeData = (_a = event.data) === null || _a === void 0 ? void 0 : _a.before.data();
    const afterData = (_b = event.data) === null || _b === void 0 ? void 0 : _b.after.data();
    // Obter o id do PDF envolvido
    const pdfId = (afterData === null || afterData === void 0 ? void 0 : afterData.pdf_id) || (beforeData === null || beforeData === void 0 ? void 0 : beforeData.pdf_id);
    if (!pdfId)
        return;
    // Buscar todos os comentários para este PDF
    const commentsSnapshot = await db.collection("comments")
        .where("pdf_id", "==", pdfId)
        .get();
    let totalRating = 0;
    const count = commentsSnapshot.size;
    commentsSnapshot.forEach((doc) => {
        const data = doc.data();
        totalRating += (data.rating || data.nota || 0);
    });
    const averageRating = count > 0 ? (totalRating / count) : 0;
    // Atualizar o documento do PDF com a nota média e quantidade de comentários
    await db.collection("pdfs").doc(pdfId).update({
        average_rating: averageRating,
        comments_count: count,
    });
});
/**
 * Função Callable para promover um usuário a administrador.
 * Apenas administradores existentes podem chamar esta função.
 */
exports.promoteToAdmin = (0, https_1.onCall)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Authentication required");
    }
    const callerUid = request.auth.uid;
    const db = admin.firestore();
    // Checar se quem está chamando é admin
    const callerDoc = await db.collection("users").doc(callerUid).get();
    if (!callerDoc.exists || callerDoc.get("role") !== "admin") {
        throw new https_1.HttpsError("permission-denied", "Admin role required to promote users");
    }
    const targetUid = request.data.userId;
    if (!targetUid) {
        throw new https_1.HttpsError("invalid-argument", "The userId parameter is required");
    }
    // 1. Atualizar Custom Claims no Auth do target
    await admin.auth().setCustomUserClaims(targetUid, { admin: true });
    // 2. Atualizar campo role no Firestore do target
    await db.collection("users").doc(targetUid).update({
        role: "admin",
    });
    return { success: true, message: `User ${targetUid} promoted to admin successfully` };
});
//# sourceMappingURL=triggers.js.map