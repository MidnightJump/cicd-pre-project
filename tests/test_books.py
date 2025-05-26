import pytest
from fastapi.testclient import TestClient

from books2 import app

client = TestClient(app)


def test_read_all_books():
    """测试获取所有书籍"""
    response = client.get("/books")
    assert response.status_code == 200
    assert len(response.json()) > 0


def test_read_book_by_id():
    """测试根据ID获取书籍"""
    response = client.get("/books/1")
    assert response.status_code == 200
    book = response.json()
    assert book["id"] == 1
    assert "title" in book


def test_read_book_not_found():
    """测试获取不存在的书籍"""
    response = client.get("/books/999")
    assert response.status_code == 404


def test_read_books_by_rating():
    """测试根据评分获取书籍"""
    response = client.get("/books/?book_rating=5")
    assert response.status_code == 200
    books = response.json()
    for book in books:
        assert book["rating"] == 5


def test_read_books_by_publish_date():
    """测试根据发布日期获取书籍"""
    response = client.get("/books/publish/?published_date=2030")
    assert response.status_code == 200
    books = response.json()
    for book in books:
        assert book["published_date"] == 2030


def test_create_book():
    """测试创建新书籍"""
    new_book = {
        "title": "Test Book",
        "author": "Test Author",
        "description": "Test Description",
        "rating": 4,
        "published_date": 2024,
    }
    response = client.post("/create-book", json=new_book)
    assert response.status_code == 201


def test_create_book_invalid_data():
    """测试创建书籍时的数据验证"""
    invalid_book = {
        "title": "AB",  # 太短
        "author": "",  # 空字符串
        "description": "Test",
        "rating": 6,  # 超出范围
        "published_date": 1999,  # 超出范围
    }
    response = client.post("/create-book", json=invalid_book)
    assert response.status_code == 422


def test_book_workflow():
    """测试完整的书籍操作工作流"""
    # 获取初始书籍数量
    response = client.get("/books")
    initial_count = len(response.json())

    # 创建新书籍
    new_book = {
        "title": "Workflow Test Book",
        "author": "Test Author",
        "description": "Integration test book",
        "rating": 5,
        "published_date": 2024,
    }
    create_response = client.post("/create-book", json=new_book)
    assert create_response.status_code == 201

    # 验证书籍数量增加
    response = client.get("/books")
    assert len(response.json()) == initial_count + 1

    # 查找新创建的书籍
    books = response.json()
    new_book_found = None
    for book in books:
        if book["title"] == "Workflow Test Book":
            new_book_found = book
            break

    assert new_book_found is not None
    assert new_book_found["author"] == "Test Author"
    assert new_book_found["rating"] == 5


def test_api_endpoints_connectivity():
    """测试API端点连通性"""
    endpoints = [
        "/books",
        "/books/1",
        "/books/?book_rating=5",
        "/books/publish/?published_date=2030",
    ]

    for endpoint in endpoints:
        response = client.get(endpoint)
        assert response.status_code in [200, 404]  # 允许404（数据不存在）
