import * as admin from "firebase-admin";

const projectId = process.env.GCLOUD_PROJECT || process.env.GOOGLE_CLOUD_PROJECT;
if (!projectId) {
  throw new Error("Set GCLOUD_PROJECT before running this migration.");
}

admin.initializeApp({projectId});

async function migrateLegacyPdfs() {
  const snapshot = await admin.firestore().collection("pdfs").get();
  const legacyDocs = snapshot.docs.filter((doc) => typeof doc.get("is_public") !== "boolean");

  for (let index = 0; index < legacyDocs.length; index += 450) {
    const batch = admin.firestore().batch();
    for (const doc of legacyDocs.slice(index, index + 450)) {
      batch.update(doc.ref, {is_public: true});
    }
    await batch.commit();
  }

  console.log(`Marked ${legacyDocs.length} legacy PDFs as public.`);
}

migrateLegacyPdfs().catch((error: unknown) => {
  console.error(error);
  process.exitCode = 1;
});