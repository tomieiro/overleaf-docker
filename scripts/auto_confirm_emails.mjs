import mongodbLegacy from 'mongodb-legacy'

const { MongoClient } = mongodbLegacy

const mongoUrl =
  process.env.MONGO_CONNECTION_STRING ||
  process.env.SHARELATEX_MONGO_URL ||
  process.env.MONGO_URL ||
  'mongodb://mongo/sharelatex'

const intervalMs = Number.parseInt(
  process.env.AUTO_CONFIRM_EMAIL_INTERVAL_MS || '5000',
  10
)

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms))
}

async function confirmPendingEmails(db) {
  const now = new Date()
  const users = db.collection('users')

  const emailResult = await users.updateMany(
    { emails: { $elemMatch: { confirmedAt: { $exists: false } } } },
    {
      $set: {
        'emails.$[email].confirmedAt': now,
        must_reconfirm: false,
      },
    },
    {
      arrayFilters: [{ 'email.confirmedAt': { $exists: false } }],
    }
  )

  const reconfirmResult = await users.updateMany(
    { must_reconfirm: true },
    { $set: { must_reconfirm: false } }
  )

  if (emailResult.modifiedCount || reconfirmResult.modifiedCount) {
    console.log(
      JSON.stringify({
        message: 'confirmed local emails',
        emailsModified: emailResult.modifiedCount,
        reconfirmFlagsModified: reconfirmResult.modifiedCount,
      })
    )
  }
}

async function main() {
  const client = new MongoClient(mongoUrl)
  await client.connect()
  const db = client.db()

  while (true) {
    try {
      await confirmPendingEmails(db)
    } catch (error) {
      console.error(error)
    }

    await sleep(intervalMs)
  }
}

main().catch(error => {
  console.error(error)
  process.exit(1)
})
