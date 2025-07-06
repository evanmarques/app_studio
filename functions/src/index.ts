/**
 * ARQUIVO: functions/src/index.ts
 * Este código usa a sintaxe moderna (v2) do Firebase Functions, corrigindo
 * os erros de compilação do TypeScript.
 */

// Importa funções específicas da v2 em vez do pacote inteiro.
import {onDocumentCreated, onDocumentUpdated} from "firebase-functions/v2/firestore";
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {logger} from "firebase-functions";

// Inicializa o Firebase Admin para que as funções tenham acesso ao projeto.
initializeApp();

/**
 * Gatilho: Disparado quando um NOVO documento é criado em 'appointments'.
 * Ação: Envia uma notificação para o ARTISTA.
 */
export const onAppointmentCreated = onDocumentCreated(
  "appointments/{appointmentId}",
  async (event) => {
    // O 'event.data' contém os dados do documento criado.
    const snapshot = event.data;
    if (!snapshot) {
      logger.log("No data associated with the event");
      return;
    }
    const appointment = snapshot.data();

    const artistId = appointment.artistId;
    const clientName = appointment.clientName;

    logger.log(`New appointment for artist ${artistId} from ${clientName}`);

    // Busca o documento do artista para encontrar seu token de notificação.
    const userDoc = await getFirestore().collection("users").doc(artistId).get();
    const userData = userDoc.data();

    if (!userData || !userData.fcmToken) {
      logger.log(`Artist ${artistId} has no FCM token.`);
      return;
    }

    const payload = {
      notification: {
        title: "Nova Solicitação de Agendamento!",
        body: `${clientName} solicitou um horário com você.`,
        sound: "default",
      },
    };

    // Envia a notificação para o dispositivo do artista.
    return getMessaging().sendToDevice(userData.fcmToken, payload);
  },
);

/**
 * Gatilho: Disparado quando um documento em 'appointments' é ATUALIZADO.
 * Ação: Envia uma notificação para o CLIENTE sobre a mudança de status.
 */
export const onAppointmentUpdated = onDocumentUpdated(
  "appointments/{appointmentId}",
  async (event) => {
    const change = event.data;
    if (!change) {
      logger.log("No data associated with the event");
      return;
    }

    const newData = change.after.data();
    const oldData = change.before.data();

    // Se o status não mudou, não faz nada.
    if (newData.status === oldData.status) {
      logger.log("Status not changed, no notification needed.");
      return;
    }

    const clientId = newData.clientId;
    const artistName = newData.artistName;
    const status = newData.status;

    const userDoc = await getFirestore().collection("users").doc(clientId).get();
    const userData = userDoc.data();

    if (!userData || !userData.fcmToken) {
      logger.log(`Client ${clientId} has no FCM token.`);
      return;
    }

    let title = "";
    let body = "";

    if (status === "confirmed") {
      title = "Agendamento Confirmado!";
      body = `Sua sessão com ${artistName} foi confirmada.`;
    } else if (status === "cancelled") {
      title = "Agendamento Cancelado";
      body = `Sua sessão com ${artistName} foi cancelada.`;
    } else {
      return; // Não notifica para outros status
    }

    const payload = {
      notification: {title, body, sound: "default"},
    };

    return getMessaging().sendToDevice(userData.fcmToken, payload);
  },
);
