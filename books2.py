from typing import List, Optional

from fastapi import Body, FastAPI, HTTPException, Path, Query
from pydantic import BaseModel, Field
from starlette import status

app = FastAPI()


class Book(BaseModel):
    id: int
    title: str
    author: str
    description: str
    rating: int
    published_date: int


class BookRequest(BaseModel):
    id: Optional[int] = Field(description="ID is not needed on create", default=None)
    title: str = Field(min_length=3)
    author: str = Field(min_length=1)
    description: str = Field(min_length=1, max_length=100)
    rating: int = Field(gt=0, lt=6)
    published_date: int = Field(gt=1999, lt=2031)

    model_config = {
        "json_schema_extra": {
            "example": {
                "title": "A new book",
                "author": "codingwithroby",
                "description": "A new description of a book",
                "rating": 5,
                "published_date": 2029,
            }
        }
    }


BOOKS = [
    Book(
        id=1,
        title="Computer Science Pro",
        author="codingwithroby",
        description="A very nice book!",
        rating=5,
        published_date=2030,
    ),
    Book(
        id=2,
        title="Be Fast with FastAPI",
        author="codingwithroby",
        description="A great book!",
        rating=5,
        published_date=2030,
    ),
    Book(
        id=3,
        title="Master Endpoints",
        author="codingwithroby",
        description="A awesome book!",
        rating=5,
        published_date=2029,
    ),
    Book(
        id=4,
        title="HP1",
        author="Author 1",
        description="Book Description",
        rating=2,
        published_date=2028,
    ),
    Book(
        id=5,
        title="HP2",
        author="Author 2",
        description="Book Description",
        rating=3,
        published_date=2027,
    ),
    Book(
        id=6,
        title="HP3",
        author="Author 3",
        description="Book Description",
        rating=1,
        published_date=2026,
    ),
]


@app.get("/books", status_code=status.HTTP_200_OK)
async def read_all_books() -> List[Book]:
    return BOOKS


@app.get("/books/{book_id}", status_code=status.HTTP_200_OK)
async def read_book(book_id: int = Path(gt=0)) -> Book:
    for book in BOOKS:
        if book.id == book_id:
            return book
    raise HTTPException(status_code=404, detail="Item not found")


@app.get("/books/", status_code=status.HTTP_200_OK)
async def read_book_by_rating(book_rating: int = Query(gt=0, lt=6)) -> List[Book]:
    books_to_return = []
    for book in BOOKS:
        if book.rating == book_rating:
            books_to_return.append(book)
    return books_to_return


@app.get("/books/publish/", status_code=status.HTTP_200_OK)
async def read_books_by_publish_date(
    published_date: int = Query(gt=1999, lt=2031)
) -> List[Book]:
    books_to_return = []
    for book in BOOKS:
        if book.published_date == published_date:
            books_to_return.append(book)
    return books_to_return


@app.post("/create-book", status_code=status.HTTP_201_CREATED)
async def create_book(book_request: BookRequest) -> None:
    new_book = Book(**book_request.model_dump())
    BOOKS.append(find_book_id(new_book))


def find_book_id(book: Book) -> Book:
    new_id = 1 if len(BOOKS) == 0 else BOOKS[-1].id + 1
    book_dict = book.model_dump()
    book_dict["id"] = new_id
    return Book(**book_dict)


@app.put("/books/update_book", status_code=status.HTTP_204_NO_CONTENT)
async def update_book(book: BookRequest) -> None:
    book_changed = False
    for i in range(len(BOOKS)):
        if BOOKS[i].id == book.id:
            updated_book = Book(**book.model_dump())
            BOOKS[i] = updated_book
            book_changed = True
    if not book_changed:
        raise HTTPException(status_code=404, detail="Item not found")


@app.delete("/books/{book_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_book(book_id: int = Path(gt=0)) -> None:
    book_changed = False
    for i in range(len(BOOKS)):
        if BOOKS[i].id == book_id:
            BOOKS.pop(i)
            book_changed = True
            break
    if not book_changed:
        raise HTTPException(status_code=404, detail="Item not found")
