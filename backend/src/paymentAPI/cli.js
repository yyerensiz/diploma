// backend/src/paymentAPI/cli.js
const { Sequelize } = require('sequelize');
const yargs = require('yargs');
const { hideBin } = require('yargs/helpers');
require('dotenv').config();

// Import your Card model (which in turn pulls in `db` from your config)
const { Card } = require('./models/card.model');

// We assume that `db` (Sequelize instance) has already been configured in config/database.config.js,
// and that importing Card triggers the model definition.
const { db } = require('../config/database.config');

async function main() {
  // Ensure DB is connected
  try {
    await db.authenticate();
    // If you’re using `sequelize.sync()` elsewhere, no need to sync here.
    // But if not, you could do: await db.sync();
  } catch (err) {
    console.error('Unable to connect to the database:', err);
    process.exit(1);
  }

  yargs(hideBin(process.argv))
    .command(
      'create',
      'Create a new card (bank account simulation)',
      (yargs) => {
        return yargs
          .option('name', {
            alias: 'n',
            type: 'string',
            describe: 'Full name on the card',
            demandOption: true
          })
          .option('card', {
            alias: 'c',
            type: 'string',
            describe: '16-digit card number',
            demandOption: true
          })
          .option('exp', {
            alias: 'e',
            type: 'string',
            describe: 'Expiration date MM/YY',
            demandOption: true
          })
          .option('cvv', {
            alias: 'v',
            type: 'string',
            describe: '3-digit CVV',
            demandOption: true
          })
          .option('balance', {
            alias: 'b',
            type: 'number',
            describe: 'Initial balance (optional, default=0)',
            default: 0
          });
      },
      async (argv) => {
        try {
          const newCard = await Card.create({
            full_name: argv.name,
            card_number: argv.card,
            exp_date: argv.exp,
            cvv: argv.cvv,
            balance: argv.balance
          });
          console.log('✅ Card created:', {
            id: newCard.id,
            full_name: newCard.full_name,
            card_number: newCard.card_number,
            balance: newCard.balance
          });
        } catch (err) {
          console.error('❌ Error creating card:', err.errors ? err.errors.map(e => e.message).join('; ') : err);
        } finally {
          await db.close();
        }
      }
    )
    .command(
      'update',
      'Update an existing card by ID',
      (yargs) => {
        return yargs
          .option('id', {
            alias: 'i',
            type: 'number',
            describe: 'Card ID to update',
            demandOption: true
          })
          .option('name', {
            alias: 'n',
            type: 'string',
            describe: 'New full_name (optional)'
          })
          .option('exp', {
            alias: 'e',
            type: 'string',
            describe: 'New exp_date (MM/YY)'
          })
          .option('cvv', {
            alias: 'v',
            type: 'string',
            describe: 'New CVV (3 digits)'
          })
          .option('balance', {
            alias: 'b',
            type: 'number',
            describe: 'New balance (non-negative number)'
          });
      },
      async (argv) => {
        try {
          const card = await Card.findByPk(argv.id);
          if (!card) {
            console.error('❌ No card found with ID', argv.id);
            return;
          }
          if (argv.name !== undefined) card.full_name = argv.name;
          if (argv.exp !== undefined) card.exp_date = argv.exp;
          if (argv.cvv !== undefined) card.cvv = argv.cvv;
          if (argv.balance !== undefined) {
            if (argv.balance < 0) {
              console.error('❌ Balance must be non-negative.');
              return;
            }
            card.balance = argv.balance;
          }
          await card.save();
          console.log('✅ Card updated:', {
            id: card.id,
            full_name: card.full_name,
            exp_date: card.exp_date,
            cvv: card.cvv,
            balance: card.balance
          });
        } catch (err) {
          console.error('❌ Error updating card:', err.errors ? err.errors.map(e => e.message).join('; ') : err);
        } finally {
          await db.close();
        }
      }
    )
    .command(
      'delete',
      'Delete a card by ID',
      (yargs) => {
        return yargs.option('id', {
          alias: 'i',
          type: 'number',
          describe: 'Card ID to delete',
          demandOption: true
        });
      },
      async (argv) => {
        try {
          const rowsDeleted = await Card.destroy({ where: { id: argv.id } });
          if (rowsDeleted === 0) {
            console.error('❌ No card found with ID', argv.id);
          } else {
            console.log(`✅ Card with ID ${argv.id} deleted.`);
          }
        } catch (err) {
          console.error('❌ Error deleting card:', err);
        } finally {
          await db.close();
        }
      }
    )
    .command(
      'list',
      'List all cards',
      () => {},
      async () => {
        try {
          const cards = await Card.findAll({ order: [['id', 'ASC']] });
          if (cards.length === 0) {
            console.log('No cards found.');
          } else {
            console.table(
              cards.map((c) => ({
                id: c.id,
                full_name: c.full_name,
                card_number: c.card_number,
                exp_date: c.exp_date,
                cvv: c.cvv,
                balance: c.balance
              }))
            );
          }
        } catch (err) {
          console.error('❌ Error listing cards:', err);
        } finally {
          await db.close();
        }
      }
    )
    .demandCommand(1, 'You must provide a valid command (create, update, delete, or list).')
    .strict()
    .help()
    .argv;
}

main();
