#!/usr/bin/env python3

print("🧪 测试 books2.py 导入...")

try:
    from books2 import app, BOOKS, Book

    print("✅ 成功导入 app, BOOKS, Book")

    # 测试Book模型
    test_book = Book(
        id=999,
        title="Test",
        author="Test Author",
        description="Test desc",
        rating=5,
        published_date=2024,
    )
    print(f"✅ 成功创建测试书籍: {test_book.title}")

    # 测试BOOKS列表
    print(f"✅ BOOKS列表包含 {len(BOOKS)} 本书")

    # 测试FastAPI应用
    from fastapi.testclient import TestClient

    client = TestClient(app)
    response = client.get("/books")

    if response.status_code == 200:
        books = response.json()
        print(f"✅ API测试成功，返回 {len(books)} 本书")
        print("🎉 所有测试通过！")
    else:
        print(f"❌ API测试失败，状态码: {response.status_code}")

except Exception as e:
    print(f"❌ 导入失败: {e}")
    import traceback

    traceback.print_exc()
