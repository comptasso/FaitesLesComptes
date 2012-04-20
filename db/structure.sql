CREATE TABLE "accounts" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "number" varchar(255), "title" varchar(255), "used" boolean DEFAULT 't', "period_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "archives" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "organism_id" integer NOT NULL, "comment" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "bank_accounts" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "number" varchar(255), "name" varchar(255), "comment" text, "address" text, "organism_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "bank_extract_lines" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "position" integer, "bank_extract_id" integer, "line_id" integer, "created_at" datetime, "updated_at" datetime, "check_deposit_id" integer);
CREATE TABLE "bank_extracts" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "bank_account_id" integer, "reference" varchar(255), "begin_date" date, "end_date" date, "begin_sold" decimal DEFAULT 0.0, "total_debit" decimal DEFAULT 0.0, "total_credit" decimal DEFAULT 0.0, "locked" boolean DEFAULT 'f', "created_at" datetime, "updated_at" datetime);
CREATE TABLE "books" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(255), "description" text, "created_at" datetime, "updated_at" datetime, "organism_id" integer, "type" varchar(255));
CREATE TABLE "cash_controls" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "cash_id" integer, "amount" decimal, "date" date, "created_at" datetime, "updated_at" datetime, "locked" boolean DEFAULT 'f');
CREATE TABLE "cashes" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "organism_id" integer, "name" varchar(255), "created_at" datetime, "updated_at" datetime, "comment" varchar(255));
CREATE TABLE "check_deposits" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "bank_account_id" integer, "deposit_date" date, "created_at" datetime, "updated_at" datetime, "bank_extract_id" integer);
CREATE TABLE "destinations" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "organism_id" integer, "comment" text, "created_at" datetime, "updated_at" datetime, "income_outcome" boolean DEFAULT 'f');
CREATE TABLE "lines" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "line_date" date, "narration" varchar(255), "nature_id" integer, "destination_id" integer, "debit" decimal DEFAULT 0.0, "credit" decimal DEFAULT 0.0, "book_id" integer, "locked" boolean DEFAULT 'f', "created_at" datetime, "updated_at" datetime, "copied_id" varchar(255), "multiple" boolean DEFAULT 'f', "bank_extract_id" integer, "payment_mode" varchar(255), "check_deposit_id" integer, "cash_id" integer, "bank_account_id" integer, "owner_id" integer, "owner_type" varchar(255));
CREATE TABLE "natures" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "comment" text, "created_at" datetime, "updated_at" datetime, "income_outcome" boolean DEFAULT 'f', "period_id" integer, "account_id" integer);
CREATE TABLE "organisms" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(255), "description" text, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "periods" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "start_date" date, "close_date" date, "organism_id" integer, "open" boolean DEFAULT 't', "created_at" datetime, "updated_at" datetime);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "transfers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "date" date, "narration" varchar(255), "debitable_id" integer, "debitable_type" varchar(255), "creditable_id" integer, "creditable_type" varchar(255), "organism_id" integer, "amount" decimal(2,10), "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20111113074749');

INSERT INTO schema_migrations (version) VALUES ('20111113120417');

INSERT INTO schema_migrations (version) VALUES ('20111113124457');

INSERT INTO schema_migrations (version) VALUES ('20111113140657');

INSERT INTO schema_migrations (version) VALUES ('20111113140717');

INSERT INTO schema_migrations (version) VALUES ('20111113145713');

INSERT INTO schema_migrations (version) VALUES ('20111116194115');

INSERT INTO schema_migrations (version) VALUES ('20111119150227');

INSERT INTO schema_migrations (version) VALUES ('20111123190507');

INSERT INTO schema_migrations (version) VALUES ('20111204075512');

INSERT INTO schema_migrations (version) VALUES ('20111205050746');

INSERT INTO schema_migrations (version) VALUES ('20111207141503');

INSERT INTO schema_migrations (version) VALUES ('20111207174346');

INSERT INTO schema_migrations (version) VALUES ('20111213055942');

INSERT INTO schema_migrations (version) VALUES ('20111215152938');

INSERT INTO schema_migrations (version) VALUES ('20111216053135');

INSERT INTO schema_migrations (version) VALUES ('20111216193243');

INSERT INTO schema_migrations (version) VALUES ('20111217072250');

INSERT INTO schema_migrations (version) VALUES ('20111220045412');

INSERT INTO schema_migrations (version) VALUES ('20111220204730');

INSERT INTO schema_migrations (version) VALUES ('20111220205809');

INSERT INTO schema_migrations (version) VALUES ('20111220211343');

INSERT INTO schema_migrations (version) VALUES ('20111220212017');

INSERT INTO schema_migrations (version) VALUES ('20111222043236');

INSERT INTO schema_migrations (version) VALUES ('20111222054832');

INSERT INTO schema_migrations (version) VALUES ('20111230102057');

INSERT INTO schema_migrations (version) VALUES ('20120101133918');

INSERT INTO schema_migrations (version) VALUES ('20120102074450');

INSERT INTO schema_migrations (version) VALUES ('20120107191029');

INSERT INTO schema_migrations (version) VALUES ('20120107191116');

INSERT INTO schema_migrations (version) VALUES ('20120108103559');

INSERT INTO schema_migrations (version) VALUES ('20120112054709');

INSERT INTO schema_migrations (version) VALUES ('20120115081616');

INSERT INTO schema_migrations (version) VALUES ('20120115084152');

INSERT INTO schema_migrations (version) VALUES ('20120130143059');

INSERT INTO schema_migrations (version) VALUES ('20120208060806');

INSERT INTO schema_migrations (version) VALUES ('20120414091600');

INSERT INTO schema_migrations (version) VALUES ('20120414160814');

INSERT INTO schema_migrations (version) VALUES ('20120419041717');