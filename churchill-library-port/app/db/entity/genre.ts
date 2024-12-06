import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToMany,
  CreateDateColumn,
  UpdateDateColumn,
  Relation,
} from "typeorm";
import { Book } from "./book";

@Entity("genres")
export class Genre {
  @PrimaryGeneratedColumn()
  id!: number

  @Column()
  name!: string

  @CreateDateColumn()
  created_at!: Date

  @UpdateDateColumn()
  updated_at!: Date

  @ManyToMany(() => Book, (book) => book.genres)
  books!: Relation<Book>[]
}
