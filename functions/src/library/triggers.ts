import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

/**
 * Recalcula a nota média e total de avaliações de um PDF sempre que um comentário é criado, editado ou excluído.
 */
export const onCommentWritten = onDocumentWritten("comments/{commentId}", async (event) => {
  const db = admin.firestore();
  
  const beforeData = event.data?.before.data();
  const afterData = event.data?.after.data();

  // Obter o id do PDF envolvido
  const pdfId = afterData?.pdf_id || beforeData?.pdf_id;
  if (!pdfId) return;

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
export const promoteToAdmin = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required");
  }

  const callerUid = request.auth.uid;
  const db = admin.firestore();

  // Checar se quem está chamando é admin
  const callerDoc = await db.collection("users").doc(callerUid).get();
  if (!callerDoc.exists || callerDoc.get("role") !== "admin") {
    throw new HttpsError("permission-denied", "Admin role required to promote users");
  }

  const targetUid = request.data.userId;
  if (!targetUid) {
    throw new HttpsError("invalid-argument", "The userId parameter is required");
  }

  // 1. Atualizar Custom Claims no Auth do target
  await admin.auth().setCustomUserClaims(targetUid, { admin: true });

  // 2. Atualizar campo role no Firestore do target
  await db.collection("users").doc(targetUid).update({
    role: "admin",
  });

  return { success: true, message: `User ${targetUid} promoted to admin successfully` };
});
