import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  OneToMany,
  CreateDateColumn,
  UpdateDateColumn,
} from "typeorm";
import { Book } from "./book";

@Entity("owners")
export class Owner {
  @PrimaryGeneratedColumn()
  id!: number

  @Column()
  name!: string

  @CreateDateColumn()
  created_at!: Date

  @UpdateDateColumn()
  updated_at!: Date

  @OneToMany(() => Book, (book) => book.owner)
  books!: Book[]
}
