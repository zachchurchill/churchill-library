# The Churchill Library

Ruby on Rails application for the Churchill Library.

More details to come.

## Database Design

```mermaid
erDiagram
  BOOKS {
    string title
  }
  OWNERS {
    string name
  }
  AUTHORS {
    string name
  }
  GENRES {
    string name
  }

  OWNERS ||--|{ BOOKS : "owns / owned by"
  AUTHORS ||--|{ BOOKS : "writes / written by"
  BOOKS }|--|{ GENRES : "categorized as / includes"
```
