import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as sgMail from '@sendgrid/mail';

const db = admin.firestore();

/**
 * グループ招待ドキュメント作成時に招待メールを送信
 * 設計書: notification-system-design.md §4
 */
export const sendInvitationEmail = functions.firestore
  .document('groups/{groupId}/invitations/{invitationId}')
  .onCreate(async (snap, context) => {
    const invitation = snap.data();
    const { groupId } = context.params;

    const apiKey = process.env.SENDGRID_API_KEY;
    if (!apiKey) {
      functions.logger.warn('SendGrid API key not configured');
      return;
    }
    sgMail.setApiKey(apiKey);

    try {
      // グループ名取得
      const groupDoc = await db
        .collection('groups')
        .doc(groupId)
        .collection('profile')
        .doc('profile')
        .get();
      const groupName = groupDoc.data()?.name || 'グループ';

      const inviteLink = `https://lifetask.app/invite/${invitation.invitationCode}`;

      const msg = {
        to: invitation.inviteeEmail,
        from: {
          email: 'noreply@lifetask.app',
          name: 'LifeTask Manager',
        },
        subject: `${invitation.invitedByName}さんがグループ「${groupName}」に招待しています`,
        html: `
          <!DOCTYPE html>
          <html>
          <head><meta charset="UTF-8"></head>
          <body style="margin: 0; padding: 0; background-color: #f5f5f5;">
            <div style="max-width: 600px; margin: 40px auto; background: white;
                        border-radius: 12px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
              <div style="background-color: #1E88E5; color: white; padding: 24px; text-align: center;">
                <h1 style="margin: 0; font-size: 24px;">✅ LifeTask Manager</h1>
              </div>
              <div style="padding: 32px;">
                <h2 style="margin-top: 0;">グループへの招待</h2>
                <p>
                  <strong>${invitation.invitedByName}</strong>さんが
                  あなたをグループ <strong>「${groupName}」</strong> に招待しました。
                </p>
                <p>LifeTask Manager でグループのタスクを一緒に管理しましょう。</p>
                <div style="text-align: center; margin: 32px 0;">
                  <a href="${inviteLink}"
                     style="display: inline-block; background-color: #1E88E5; color: white;
                            padding: 14px 32px; border-radius: 8px; text-decoration: none;
                            font-size: 16px; font-weight: bold;">
                    グループに参加する
                  </a>
                </div>
                <p style="color: #666; font-size: 14px;">
                  ※ このリンクは7日間有効です。<br>
                  ※ LifeTask Manager アプリをまだお持ちでない場合は、
                  <a href="https://lifetask.app">こちら</a>からインストールできます。
                </p>
              </div>
              <div style="background: #f9f9f9; padding: 16px; text-align: center; color: #aaa; font-size: 12px;">
                LifeTask Manager — 人生の大事なタスクを、もれなく管理<br>
                <a href="https://lifetask.app/unsubscribe" style="color: #aaa;">通知を解除</a>
              </div>
            </div>
          </body>
          </html>
        `,
      };

      await sgMail.send(msg);
      functions.logger.info(`Invitation email sent to ${invitation.inviteeEmail}`);
    } catch (error) {
      functions.logger.error('Error sending invitation email:', error);
    }
  });
