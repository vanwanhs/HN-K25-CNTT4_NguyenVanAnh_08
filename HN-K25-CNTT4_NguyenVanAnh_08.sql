create  database HK3;
use HK3;
create table Readers(
	reader_id int auto_increment primary key,
    full_name varchar(50) not null,
    email varchar(100) not null unique,
    phone_number varchar(20) not null,
    created_at date default (current_date)
);

create table Membership_Details(
	card_number varchar(50) primary key,
    reader_id int unique,
    foreign key (reader_id) references Readers(reader_id),
    type_card enum('Standard','VIP') not null,
    expiry_date date not null,
    citizen_id varchar(50) unique not null
);

create table Categories (
	category_id int auto_increment primary key,
    category_name varchar(50) not null,
    description text
);

create table Books(
	book_id int auto_increment primary key,
    title varchar(50) not null,
    author varchar(50) not null,
	category_id int not null,
    foreign key (category_id) references Categories(category_id),
    price decimal(10,2) check(price > 0),
    stock_quantity int check(stock_quantity >= 0)
);

create table Loan_Records(
	loan_id varchar(20) primary key,
    book_id int not null,
    foreign key (book_id) references Books(book_id),
    reader_id int not null,
    foreign key (reader_id) references Readers(reader_id),
    borrow_date date not null,
    return_date date,
    due_date date not null,
    check (due_date > borrow_date)
);

-- Viết script INSERT để chèn dữ liệu mẫu vào 5 bảng

insert into Readers(full_name,email,phone_number,created_at) values
('Nguyen Van A','anv@gmail.com','0901234567','2022-01-15'),
('Tran Thi B','btt@gmail.com','0912345678','2022-05-20'),
('Le Van C','cle@yahoo.com','0922334455','2023-02-10'),
('Pham Minh D','dpham@hotmail.com','0933445566','2023-11-05'),
('Hoang Anh E','ehoang@gmail.com','0944556677','2024-01-12');

insert into Membership_Details(card_number,reader_id,type_card,expiry_date,citizen_id) values
('CARD-001',1,'Standard','2025-01-15','123456789'),
('CARD-002',2,'VIP','2025-05-20','234567890'),
('CARD-003',3,'Standard','2024-02-10','345678901'),
('CARD-004',4,'VIP','2025-11-05','456789012'),
('CARD-005',5,'Standard','2026-01-12','567890123');

insert into Categories(category_name,description) values 
('IT','Sách về công nghệ thông tin và lập trình'),
('Kinh Te','Sách kinh doanh, tài chính, khởi nghiệp'),
('Van Hoc','Tiểu thuyết, truyện ngắn, thơ'),
('Ngoai Ngu','Sách học tiếng Anh, Nhật, Hàn'),
('Lich Su','Sách nghiên cứu lịch sử, văn hóa');

insert into Books(title,author,category_id,price,stock_quantity) values
('Clean Code','Robert C. Martin',1,450000,10),
('Dac Nhan Tam','Dale Carnegie',2,150000,50),
('Harry Potter 1','J.K. Rowling',3,250000,5),
('IELTS Reading','Cambridge',4,180000,0),
('Nihongo','Bich sensei',4,380000,8),
('Math basic','Hong Nhung',3,80000,2),
('Dai Viet Su Ky','Le Van Huu',5,300000,20);

insert into Loan_Records(loan_id,reader_id,book_id,borrow_date,due_date,return_date) values
('101',1,1,'2023-11-15','2023-11-22','2023-11-20'),
('102',2,2,'2023-12-01','2023-12-08','2023-12-05'),
('103',1,3,'2024-01-10','2024-01-17',NULL),
('104',3,3,'2023-05-20','2023-05-27',NULL),
('105',4,1,'2024-01-18','2024-01-25',NULL);

  -- Gia hạn thêm 7 ngày cho due_date (Ngày dự kiến trả) đối với tất cả các phiếu mượn sách thuộc danh mục 'Van Hoc' mà chưa được trả (return_date IS NULL).
update Loan_Records lr
join Books b on lr.book_id = b.book_id
join Categories c on b.category_id = c.category_id
set lr.due_date = date_add(lr.due_date, interval 7 day)
where c.category_name = 'Van Hoc' and lr.return_date IS NULL;

-- Xóa các hồ sơ mượn trả (Loan_Records) đã hoàn tất trả sách (return_date KHÔNG NULL) và có ngày mượn trước tháng 10/2023.

delete from Loan_Records
where return_date is not null
and borrow_date < '2023-10-01';


-- PHẦN 2: TRUY VẤN DỮ LIỆU CƠ BẢN

-- Câu 1
select b.book_id, b.title, b.price
from Books b
join Categories c on b.category_id = c.category_id
where c.category_name = 'IT'
and b.price > 200000;

-- Câu 2
select reader_id, full_name, email
from Readers
where year(created_at) = 2022
and email like '%@gmail.com';

-- Câu 3
select book_id, title, price
from Books
order by price desc
limit 5 offset 2;

-- PHẦN 3: TRUY VẤN DỮ LIỆU NÂNG CAO

-- Câu 1 (6đ): Viết truy vấn để hiển thị các thông tin gômg: Mã phiếu, Tên độc giả, Tên sách, Ngày mượn, Ngày trả. Chỉ hiển thị các đơn mượn chưa trả sách.
select l.loan_id, r.full_name, b.title, l.borrow_date, l.return_date
from Loan_Records l
join Readers r on l.reader_id = r.reader_id
join Books b on l.book_id = b.book_id
where l.return_date is null;


-- Câu 2 (7đ): Tính tổng số lượng sách đang tồn kho (stock_quantity) của từng danh mục (category_name). Chỉ hiển thị những danh mục có tổng tồn kho lớn hơn 10.
select c.category_name, sum(b.stock_quantity) as total_stock
from Categories c
join Books b on c.category_id = b.category_id
group by c.category_name
having total_stock > 10;

-- Câu 3 (7đ): Tìm ra thông tin độc giả (full_name) có hạng thẻ là 'VIP' nhưng chưa từng mượn cuốn sách nào có giá trị lớn hơn 300.000 VNĐ.
select r.full_name
from Readers r
join Membership_Details m on r.reader_id = m.reader_id
where m.type_card = 'VIP'
and r.reader_id not in (
    select lr.reader_id
    from Loan_Records lr
    join Books b on lr.book_id = b.book_id
    where b.price > 300000
);

-- PHẦN 4: INDEX VÀ VIEW (10 ĐIỂM)
create index idx_loan_dates on Loan_Records(borrow_date, return_date);
create view vw_overdue_loans as
select l.loan_id, r.full_name, b.title, l.borrow_date, l.due_date from Loan_Records l
join Readers r on l.reader_id = r.reader_id
join Books b on l.book_id = b.book_id
where l.return_date is null and curdate() > l.due_date;

-- test
 show index from Loan_Records;

-- PHẦN 5: TRIGGER (10 ĐIỂM)
-- Câu 1 (5đ): Viết Trigger trg_after_loan_insert. Khi một phiếu mượn mới được thêm vào bảng Loan_Records, 
-- hãy tự động trừ số lượng tồn kho (stock_quantity) của cuốn sách tương ứng trong bảng Books đi 1 đơn vị.
delimiter //
create trigger trg_after_loan_insert
after insert on Loan_Records
for each row
begin
    update Books set stock_quantity = stock_quantity - 1
    where book_id = new.book_id;
end//
delimiter ;

select book_id, stock_quantity from Books where book_id = 1;
insert into Loan_Records (loan_id, reader_id, book_id, borrow_date, due_date)values
('1001', 1, 1, curdate(), date_add(curdate(), interval 7 day));
select book_id, stock_quantity from Books where book_id = 1;

-- Câu 2 (5đ): Viết Trigger trg_prevent_delete_active_reader. Ngăn chặn việc xóa thông tin độc giả trong bảng Readers
-- nếu độc giả đó vẫn còn sách đang mượn (tức là tồn tại bản ghi trong Loan_Records mà return_date là NULL). Gợi ý: Sử dụng SIGNAL SQLSTATE.

delimiter //
create trigger trg_prevent_delete_active_reader
before delete on Readers
for each row
begin
    if exists (
        select 1 from Loan_Records where reader_id = old.reader_id and return_date is null
    ) then
        signal sqlstate '45000' set message_text = 'Doc gia dang muon sach, khong the xoa';
    end if;
end//
delimiter ;

-- delete from Readers where reader_id = 1;


-- PHẦN 6: STORED PROCEDURE (20 ĐIỂM)
-- - Câu 1 (10đ): Viết Procedure sp_check_availability nhận vào Mã sách (p_book_id). Procedure trả về thông báo qua tham số OUT p_message:
--   - 'Hết hàng' nếu tồn kho = 0.
--   - 'Sắp hết' nếu 0 < tồn kho <= 5.
--   - 'Còn hàng' nếu tồn kho > 5.
delimiter //

create procedure sp_check_availability(
    in p_book_id int
)
begin
    declare qty int;
    declare message varchar(50);

    select stock_quantity into qty from Books
    where book_id = p_book_id;
    if qty = 0 then set message = 'Het hang';
    elseif qty <= 5 then set message = 'Sap het';
    else
        set  message = 'Con hang';
    end if;
    select message as Thong_bao;
end//
delimiter ;
call sp_check_availability(1);

-- Câu 2 (10đ): Viết Procedure sp_return_book_transaction để xử lý trả sách an toàn với Transaction:
  -- Input: p_loan_id.
delimiter //
create procedure sp_return_book_transaction(
    in p_loan_id varchar(20)
)
begin
    declare v_book_id int;
    declare v_return_date date;

    start transaction;

    select book_id, return_date into v_book_id, v_return_date from Loan_Records 
    where loan_id = p_loan_id
    for update;
    if v_return_date is not null then
        rollback;
        signal sqlstate '45000' set message_text= 'Sach da tra roi';
    end if;

    update Loan_Records set return_date = curdate() where loan_id = p_loan_id;
    update Books set stock_quantity = stock_quantity + 1 where book_id = v_book_id;
    commit;
    select 'Tra sach thanh cong' as thong_bao;
end//

delimiter ;

call sp_return_book_transaction('103');

