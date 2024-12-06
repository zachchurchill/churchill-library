import { DataSource } from "typeorm";
import { Author } from "./entity/author";
import { Book } from "./entity/book";
import { Genre } from "./entity/genre";
import { Owner } from "./entity/owner";

export const AppDataSource = new DataSource({
  type: "postgres",
  host: "localhost",
  port: 3432,
  username: "zach",
  password: "churchilllibdev",
  database: "churchilllib",
  synchronize: false,
  logging: true,
  entities: [Author, Owner, Genre, Book],
});

await AppDataSource.initialize()
  .then(() => {})
  .catch((error) => console.log(error));
