--Nhóm 3
--Nguyễn Quốc Gia Huy 2001215823
--Nguyễn Đức Phát 2001216020
--Lương Công Nhã Quân 2001216077

--Tạo các bảng
CREATE TABLE BAN
(
    IDBAN VARCHAR2(20) PRIMARY KEY,
    TENBAN NVARCHAR2(50) UNIQUE,
    TRANGTHAI NUMBER(1,0) DEFAULT 0 -- 1: CÓ KHÁCH, 0: KHÔNG CÓ KHÁCH
);

CREATE TABLE LOAI
(
    IDLOAI VARCHAR2(20) PRIMARY KEY,
    TENLOAI NVARCHAR2(50) UNIQUE
);

CREATE TABLE MON
(
    IDMON VARCHAR2(20) PRIMARY KEY,
    TENMON NVARCHAR2(50) UNIQUE,
    IDLOAI VARCHAR2(20),
    GIA NUMBER CHECK (GIA >= 0),
    MOTA CLOB,
    TRANGTHAI NUMBER(1,0) DEFAULT 1,
    CONSTRAINT FK_MON_LOAI FOREIGN KEY(IDLOAI) REFERENCES LOAI(IDLOAI)
);

CREATE TABLE TAIKHOAN
(
    IDTAIKHOAN VARCHAR2(50) PRIMARY KEY,
    TENHIENTHI NVARCHAR2(50),
    TENDANGNHAP VARCHAR2(50) UNIQUE,
    MATKHAU VARCHAR2(50),
    CHUCVU NVARCHAR2(50)
);

CREATE TABLE NHANSU
(
    MANV VARCHAR2(50) PRIMARY KEY,
    HOTEN VARCHAR2(50),
    PHONG VARCHAR2(50),
    CHUCVU VARCHAR2(50),
    TAIKHOAN VARCHAR2(50),
    CONSTRAINT FK_NHANSU_TAIKHOAN FOREIGN KEY(TAIKHOAN) REFERENCES TAIKHOAN(IDTAIKHOAN)
);

CREATE TABLE HOADON
(
    IDHOADON VARCHAR2(30) PRIMARY KEY,
    TENKHACHHANG NVARCHAR2(50),
    NGAYNHAP DATE DEFAULT SYSDATE,
    IDBAN VARCHAR2(20) NOT NULL,
    TONGTIEN NUMBER,
    GIAMGIA NUMBER,
    THANHTOAN NUMBER,
    TRANGTHAI NUMBER(1,0) DEFAULT 0,
    CONSTRAINT FK_HOADON_BAN FOREIGN KEY(IDBAN) REFERENCES BAN(IDBAN)
);

CREATE TABLE CHITIETHOADON
(
    IDHOADON VARCHAR2(30) NOT NULL,
    IDMON VARCHAR2(20) NOT NULL,
    SOLUONG NUMBER DEFAULT 1,
    GIA NUMBER,
    GIAMGIA NUMBER,
    THANHTIEN NUMBER,
    CONSTRAINT PK_CHITIETHOADON PRIMARY KEY (IDHOADON, IDMON),
    CONSTRAINT FK_CHITIETHOADON_MON FOREIGN KEY(IDMON) REFERENCES MON(IDMON),
    CONSTRAINT FK_CHITIETHOADON_HOADON FOREIGN KEY(IDHOADON) REFERENCES HOADON(IDHOADON) 
);

--Tạo các sequence
CREATE SEQUENCE SEQ_IDBAN
START WITH 1
INCREMENT BY 1
NOMAXVALUE;

CREATE SEQUENCE SEQ_IDLOAI
START WITH 1
INCREMENT BY 1
NOMAXVALUE;

CREATE SEQUENCE SEQ_IDMON
START WITH 1
INCREMENT BY 1
NOMAXVALUE;

CREATE SEQUENCE SEQ_IDTAIKHOAN
START WITH 1
INCREMENT BY 1
NOMAXVALUE;

CREATE SEQUENCE SEQ_IDNS
START WITH 1
INCREMENT BY 1
NOMAXVALUE;

CREATE SEQUENCE SEQ_IDHD
START WITH 1
INCREMENT BY 1
NOMAXVALUE;

--Tạo các hàm

--Tạo id bàn
CREATE OR REPLACE FUNCTION CREATE_IDBAN RETURN VARCHAR2 IS
    STT VARCHAR2(2);
    ID VARCHAR2(10);
BEGIN

    SELECT LPAD(SEQ_IDBAN.NEXTVAL, 2, '0') INTO STT FROM DUAL;

    ID := 'B' || STT;
    RETURN ID;
END CREATE_IDBAN;

--Tạo id loại
CREATE OR REPLACE FUNCTION CREATE_IDLOAI RETURN VARCHAR2 IS
    STT VARCHAR2(2);
    ID VARCHAR2(10);
BEGIN

    SELECT LPAD(SEQ_IDLOAI.NEXTVAL, 2, '0') INTO STT FROM DUAL;

    ID := 'L' || STT;
    RETURN ID;
END CREATE_IDLOAI;

--Tạo id món
CREATE OR REPLACE FUNCTION CREATE_IDMON RETURN VARCHAR2 IS
    STT VARCHAR2(2);
    ID VARCHAR2(10);
BEGIN

    SELECT LPAD(SEQ_IDMON.NEXTVAL, 2, '0') INTO STT FROM DUAL;

    ID := 'M' || STT;
    RETURN ID;
END CREATE_IDMON;

--Tạo id tài khoản
CREATE FUNCTION CREATE_IDTAIKHOAN RETURN VARCHAR2 IS
    STT VARCHAR2(2);
    ID VARCHAR2(10);
BEGIN

    SELECT LPAD(SEQ_IDTAIKHOAN.NEXTVAL, 2, '0') INTO STT FROM DUAL;

    ID := 'TK' || STT;
    RETURN ID;
END CREATE_IDTAIKHOAN;

--Tạo id nhân sự

--Tạo id hóa đơn
CREATE FUNCTION CREATE_IDHD RETURN VARCHAR2 IS
    ddmmyy VARCHAR2(8);
    STT VARCHAR2(4);
    ID VARCHAR2(30);
BEGIN
    SELECT TO_CHAR(SYSDATE, 'DD') || LPAD(TO_CHAR(SYSDATE, 'MM'), 2, '0') || TO_CHAR(SYSDATE, 'YYYY') INTO ddmmyy FROM DUAL;

    SELECT LPAD(SEQ_IDHD.NEXTVAL, 4, '0') INTO STT FROM DUAL;

    ID := 'HD' || ddmmyy || STT;
    RETURN ID;
END CREATE_IDHD;

--Tạo các thủ tục

--Thêm bàn
CREATE PROCEDURE THEMBAN(TEN NVARCHAR2, TRANGTHAI_BAN NUMBER) IS
BEGIN
  INSERT INTO BAN (IDBAN, TENBAN, TRANGTHAI) VALUES
  (CREATE_IDBAN, TEN, TRANGTHAI_BAN); COMMIT;
END THEMBAN;

--Xóa bàn
CREATE PROCEDURE XOABAN(ID VARCHAR2) IS
BEGIN
  DELETE FROM CHITIETHOADON WHERE IDHOADON IN (SELECT IDHOADON FROM HOADON WHERE IDBAN = ID);
  DELETE FROM HOADON WHERE IDBAN = ID;
  DELETE FROM BAN WHERE IDBAN = ID;
  COMMIT;
END;

--Sửa bàn
CREATE PROCEDURE SUABAN(ID VARCHAR2, TEN NVARCHAR2, TRANGTHAI_BAN NUMBER) IS
BEGIN
  UPDATE BAN 
  SET TENBAN = TEN, TRANGTHAI = TRANGTHAI_BAN
  WHERE IDBAN = ID;
  COMMIT;
END SUABAN;

--Thêm loại
CREATE PROCEDURE THEMLOAI(TEN NVARCHAR2) IS
BEGIN
  INSERT INTO LOAI (IDLOAI, TENLOAI) VALUES
  (CREATE_IDLOAI, TEN); COMMIT;
END THEMLOAI;

--Xóa loại
CREATE PROCEDURE XOALOAI(ID VARCHAR2) IS
BEGIN
  DELETE FROM CHITIETHOADON WHERE IDMON IN (SELECT IDMON FROM MON WHERE IDLOAI = ID);
  DELETE FROM MON WHERE IDLOAI = ID;
  DELETE FROM LOAI WHERE IDLOAI = ID;
  COMMIT;
END;

--Sửa loại
CREATE PROCEDURE SUALOAI(ID VARCHAR2, TEN NVARCHAR2) IS
BEGIN
  UPDATE LOAI 
  SET TENLOAI = TEN
  WHERE IDLOAI = ID;
  COMMIT;
END SUALOAI;

--Thêm món
CREATE PROCEDURE THEMMON(TEN NVARCHAR2, LOAI VARCHAR2, GIAMON NUMBER, MOTA_MON CLOB, TRANGTHAI_MON NUMBER) 
IS
BEGIN
  INSERT INTO MON (IDMON, TENMON, IDLOAI, GIA, MOTA, TRANGTHAI) VALUES
  (CREATE_IDMON, TEN, LOAI, GIAMON, MOTA_MON, TRANGTHAI_MON); COMMIT;
END THEMMON;

--Xóa món
CREATE PROCEDURE XOAMON(ID NUMBER) IS
  DANGBAN NUMBER;
BEGIN
  SELECT COUNT(*) INTO DANGBAN
  FROM CHITIETHOADON, HOADON
  WHERE CHITIETHOADON.IDMON = ID AND CHITIETHOADON.IDHOADON = HOADON.IDHOADON AND HOADON.TRANGTHAI = 0;

  IF DANGBAN = 0 THEN
    DELETE FROM CHITIETHOADON WHERE IDMON = ID;
    DELETE FROM MON WHERE IDMON = ID;
    COMMIT;
  ELSE 
    RAISE_APPLICATION_ERROR(-20001, N'MÓN HI?N V?N ?ANG ???C BÁN');
  END IF;
END;

--Sửa món
CREATE PROCEDURE SUAMON(ID VARCHAR2, TEN NVARCHAR2, LOAI VARCHAR2, GIAMON NUMBER, MOTA_MON CLOB, TRANGTHAI_MON NUMBER) IS
BEGIN
  UPDATE MON
  SET TENMON = TEN, IDLOAI = LOAI, GIA = GIAMON, MOTA = MOTA_MON, TRANGTHAI = TRANGTHAI_MON
  WHERE IDMON = ID;
  COMMIT;
END SUAMON;

--Tạo hóa đơn
create or replace PROCEDURE TAOHOADON(NAMEGUEST IN NVARCHAR2, IDBANDANGCHON IN VARCHAR2) IS
BEGIN
    INSERT INTO HOADON(IDHOADON, TENKHACHHANG, IDBAN, TONGTIEN, GIAMGIA, THANHTOAN, TRANGTHAI)
    VALUES(CREATE_IDHD, NAMEGUEST, IDBANDANGCHON, 0, 0, 0, 0);

    UPDATE BAN 
    SET TRANGTHAI = 1 
    WHERE IDBAN = IDBANDANGCHON;

    COMMIT;
END;

--Sửa hóa đơn
create or replace PROCEDURE SUAHOADON(ID VARCHAR2, TENKH NVARCHAR2, BAN VARCHAR2, TT NUMBER) IS
BEGIN
    UPDATE HOADON
    SET TENKHACHHANG = TENKH, IDBAN = BAN
    WHERE IDHOADON = ID;
    COMMIT;
END;

--Xóa hóa đơn
create or replace PROCEDURE XOAHOADON(ID VARCHAR2) IS
BEGIN
    DELETE FROM CHITIETHOADON WHERE IDHOADON = ID;
    DELETE FROM HOADON WHERE IDHOADON = ID; 
    COMMIT;
END;

--Thêm chi tiết hóa đơn
create or replace PROCEDURE THEMCTHD(HOADON VARCHAR2, MON VARCHAR2, SL NUMBER) IS
    GIA_MON NUMBER;
    TIEN NUMBER;
BEGIN
    SELECT GIA INTO GIA_MON FROM caphe.MON WHERE IDMON = MON;
    TIEN := GIA_MON * SL;
    INSERT INTO CHITIETHOADON(IDHOADON, IDMON, SOLUONG, GIA, GIAMGIA, THANHTIEN) VALUES
    (HOADON, MON, SL, GIA_MON, 0, TIEN); COMMIT;

END;

--Sửa chi tiết hóa đơn
create or replace PROCEDURE SUACTHD(HOADON VARCHAR2, MON VARCHAR2, SL NUMBER) IS
BEGIN
    UPDATE CHITIETHOADON
    SET SOLUONG = SL
    WHERE IDHOADON = HOADON AND IDMON = MON;

    UPDATE CHITIETHOADON
    SET THANHTIEN = GIA * SL
    WHERE IDHOADON = HOADON AND IDMON = MON;
    COMMIT;
END;

--Xóa chi tiết hóa đơn
create or replace PROCEDURE XOACTHD(HOADON VARCHAR2, MON VARCHAR2) IS
BEGIN
    DELETE FROM CHITIETHOADON WHERE IDHOADON = HOADON AND IDMON = MON; 
    COMMIT;
END;

--Thêm tài khoản
create or replace PROCEDURE THEMTAIKHOAN(TK VARCHAR2, MK VARCHAR2) IS
    TEN VARCHAR2(50);
BEGIN
  SELECT HOTEN INTO TEN FROM NHANSU WHERE TAIKHOAN = TK;
  INSERT INTO TAIKHOAN (IDTAIKHOAN, TENHIENTHI, TENDANGNHAP, MATKHAU) 
  VALUES(CREATE_IDTAIKHOAN, TEN, TK, MK); COMMIT;
END THEMTAIKHOAN;

--Sửa tài khoản
create or replace PROCEDURE SUATAIKHOAN(ID VARCHAR2, TEN NVARCHAR2, TK VARCHAR2, MK VARCHAR2) IS
BEGIN
  UPDATE TAIKHOAN 
  SET TENHIENTHI = TEN, TENDANGNHAP = TK, MATKHAU = MK
  WHERE IDTAIKHOAN = ID;
  COMMIT;
END SUATAIKHOAN;

--Xóa tài khoản
create or replace PROCEDURE XOATAIKHOAN(ID VARCHAR2) IS
BEGIN
  DELETE
  FROM TAIKHOAN
  WHERE IDTAIKHOAN = ID;
  COMMIT;
END;

--Tạo các trigger
create or replace TRIGGER UPT_THANHTIEN
AFTER INSERT OR UPDATE ON CHITIETHOADON
FOR EACH ROW
DECLARE
BEGIN
    IF INSERTING THEN
        UPDATE caphe.HOADON
        SET TONGTIEN = TONGTIEN + :NEW.SOLUONG * :NEW.THANHTIEN
        WHERE IDHOADON = :NEW.IDHOADON;
    END IF;
    IF UPDATING('SOLUONG') THEN
        IF :NEW.SOLUONG > :OLD.SOLUONG THEN
            UPDATE caphe.HOADON
            SET TONGTIEN = TONGTIEN + (:NEW.SOLUONG - :OLD.SOLUONG) * :NEW.THANHTIEN
            WHERE IDHOADON = :NEW.IDHOADON;
        ELSIF :NEW.SOLUONG < :OLD.SOLUONG THEN
            UPDATE caphe.HOADON
            SET TONGTIEN = TONGTIEN + (:OLD.SOLUONG - :NEW.SOLUONG) * :NEW.THANHTIEN
            WHERE IDHOADON = :NEW.IDHOADON;
        END IF;
    END IF;

    UPDATE caphe.HOADON
    SET THANHTOAN = TONGTIEN - TONGTIEN * GIAMGIA
    WHERE IDHOADON = :NEW.IDHOADON;

END UPT_THANHTIEN;

--Tạo các role
CREATE ROLE GD_CAPHE;
CREATE ROLE QT_ADMIN;
CREATE ROLE KT_QUANLY;
CREATE ROLE KT_NHANVIEN;
CREATE ROLE BH_NHANVIEN;
CREATE ROLE BH_QUANLY;

--Gán các quyền cho role
GRANT SELECT, INSERT, UPDATE, DELETE ON caphe.NHANSU TO GD_CAPHE;
GRANT SELECT, INSERT, UPDATE, DELETE ON caphe.CHITIETHOADON TO BH_QUANLY;
GRANT SELECT, INSERT, UPDATE, DELETE ON caphe.HOADON TO GD_CAPHE;
GRANT SELECT, INSERT, UPDATE, DELETE ON caphe.CHITIETHOADON TO GD_CAPHE;

GRANT SELECT ON caphe.NHANSU TO BH_NHANVIEN;
GRANT SELECT ON caphe.NHANSU TO KT_NHANVIEN;
GRANT SELECT ON caphe.TAIKHOAN TO BH_QUANLY;
GRANT SELECT ON caphe.TAIKHOAN TO KT_NHANVIEN;

GRANT SELECT, INSERT, UPDATE, DELETE ON caphe.HOADON TO BH_QUANLY;
GRANT SELECT, INSERT, UPDATE, DELETE ON caphe.HOADON TO BH_NHANVIEN;
GRANT SELECT, INSERT, UPDATE, DELETE ON caphe.CHITIETHOADON TO BH_QUANLY;
GRANT SELECT, INSERT, UPDATE, DELETE ON caphe.CHITIETHOADON TO BH_NHANVIEN;

--Gán role cho các user
GRANT QT_ADMIN TO admin;
GRANT KT_QUANLY to kt_quanly1;
GRANT KT_NHANVIEN to kt_nhanvien1;
GRANT BH_QUANLY to bh_quanly1;
GRANT BH_NHANVIEN to bh_nhanvien1;
GRANT GD_CAPHE TO caphe;

--Gán quyền sử dụng các thủ tục và sequence cho các role
GRANT SELECT ON SEQ_IDMON TO BH_QUANLY;
GRANT SELECT ON SEQ_IDLOAI TO BH_QUANLY;
GRANT SELECT ON SEQ_IDBAN TO BH_QUANLY;
GRANT SELECT ON SEQ_IDHD TO BH_QUANLY;
GRANT SELECT ON SEQ_IDHD TO BH_NHANVIEN;
GRANT EXECUTE ON THEMLOAI TO BH_QUANLY;
GRANT EXECUTE ON SUALOAI TO BH_QUANLY;
GRANT EXECUTE ON XOALOAI TO BH_QUANLY;
GRANT EXECUTE ON THEMMON TO BH_QUANLY;
GRANT EXECUTE ON XOAMON TO BH_QUANLY;
GRANT EXECUTE ON SUAMON TO BH_QUANLY;
GRANT EXECUTE ON THEMBAN TO BH_QUANLY;
GRANT EXECUTE ON XOABAN TO BH_QUANLY;
GRANT EXECUTE ON SUABAN TO BH_QUANLY;
GRANT EXECUTE ON TAOHOADON TO BH_QUANLY;
GRANT EXECUTE ON XOAHOADON TO BH_QUANLY;
GRANT EXECUTE ON SUAHOADON TO BH_QUANLY;
GRANT EXECUTE ON TAOHOADON TO BH_NHANVIEN;
GRANT EXECUTE ON SUAHOADON TO BH_NHANVIEN;
GRANT SELECT ON SEQ_IDTAIKHOAN TO QT_ADMIN;
GRANT EXECUTE ON THEMCTHD TO BH_QUANLY;
GRANT EXECUTE ON THEMCTHD TO BH_NHANVIEN;
GRANT EXECUTE ON SPDOANHTHU TO KT_QUANLY;
GRANT EXECUTE ON SPDOANHTHU TO KT_NHANVIEN;

GRANT EXECUTE ON SPINHOADON TO BH_NHANVIEN;
GRANT EXECUTE ON SPINHOADON TO BH_QUANLY;

GRANT EXECUTE ON CREATE_IDMON TO BH_QUANLY;
GRANT EXECUTE ON CREATE_IDBAN TO BH_QUANLY;
GRANT EXECUTE ON CREATE_IDLOAI TO BH_QUANLY;
GRANT TRIGGER ON UPT_TONGTIEN TO BH_QUANLY;

GRANT EXECUTE ON THEMTAIKHOAN TO QT_ADMIN;
GRANT EXECUTE ON XOATAIKHOAN TO QT_ADMIN;
GRANT EXECUTE ON SUATAIKHOAN TO QT_ADMIN;

--Áp dụng mô hình OLS (Oracle Label Security) để bảo mật cơ sở dữ liệu

--Tạo policy
EXECUTE SA_SYSDBA.CREATE_POLICY (policy_name => 'CHINHSACH', column_name => 'OLS_COLUMN');

--Tạo level
EXECUTE SA_COMPONENTS.CREATE_LEVEL (policy_name => 'CHINHSACH', level_num => 30, short_name => 'HS', long_name => 'HIGHLY_SENSITIVE'); 
EXECUTE SA_COMPONENTS.CREATE_LEVEL (policy_name => 'CHINHSACH', level_num => 20, short_name => 'S', long_name => 'SENSITIVE');
EXECUTE SA_COMPONENTS.CREATE_LEVEL (policy_name => 'CHINHSACH', level_num => 10, short_name => 'C', long_name => 'CONFIDENTIAL'); 

--Tạo compartment
EXECUTE SA_COMPONENTS.CREATE_COMPARTMENT (policy_name => 'CHINHSACH', comp_num => 75, short_name => 'GD', long_name => 'GIAM DOC'); 
EXECUTE SA_COMPONENTS.CREATE_COMPARTMENT (policy_name => 'CHINHSACH', comp_num => 65, short_name => 'QT', long_name => 'QUAN TRI'); 
EXECUTE SA_COMPONENTS.CREATE_COMPARTMENT (policy_name => 'CHINHSACH', comp_num => 55, short_name => 'KT', long_name => 'KE TOAN'); 
EXECUTE SA_COMPONENTS.CREATE_COMPARTMENT (policy_name => 'CHINHSACH', comp_num => 45, short_name => 'BH', long_name => 'BAN HANG'); 

--Tạo group
EXECUTE SA_COMPONENTS.CREATE_GROUP (policy_name => 'CHINHSACH', group_num => 200, short_name => 'CP', long_name => 'CA PHE');
EXECUTE SA_COMPONENTS.CREATE_GROUP (policy_name => 'CHINHSACH', group_num => 210, short_name => 'AD', long_name => 'ADMIN', parent_name => 'CP');
EXECUTE SA_COMPONENTS.CREATE_GROUP (policy_name => 'CHINHSACH', group_num => 220, short_name => 'QL', long_name => 'QUAN LY', parent_name => 'AD'); 
EXECUTE SA_COMPONENTS.CREATE_GROUP (policy_name => 'CHINHSACH', group_num => 230, short_name => 'NV', long_name => 'NHAN VIEN', parent_name => 'QL'); 

--Tạo label
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL (policy_name => 'CHINHSACH', label_tag => '90', label_value => 'HS:GD,QT,KT,BH:CP');   
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL (policy_name => 'CHINHSACH', label_tag => '100', label_value => 'HS:QT,KT,BH:AD');   
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL (policy_name => 'CHINHSACH', label_tag => '110', label_value => 'S:KT:QL');   
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL (policy_name => 'CHINHSACH', label_tag => '120', label_value => 'C:KT:NV');   
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL (policy_name => 'CHINHSACH', label_tag => '130', label_value => 'S:BH:QL');   
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL (policy_name => 'CHINHSACH', label_tag => '140', label_value => 'C:BH:NV');   

--Áp dụng chính sách cho bảng
EXECUTE SA_POLICY_ADMIN.APPLY_TABLE_POLICY (policy_name => 'CHINHSACH', schema_name => 'caphe', table_name => 'NHANSU', table_options => 'LABEL_DEFAULT, READ_CONTROL, WRITE_CONTROL');
EXECUTE SA_POLICY_ADMIN.APPLY_TABLE_POLICY (policy_name => 'CHINHSACH', schema_name => 'caphe', table_name => 'TAIKHOAN', table_options => 'LABEL_DEFAULT, READ_CONTROL, WRITE_CONTROL');

--Gán nhãn bảo mật cho các user
EXECUTE SA_USER_ADMIN.SET_USER_LABELS (policy_name => 'CHINHSACH', user_name => 'caphe', max_read_label => 'HS:GD,QT,KT,BH:CP', max_write_label => 'HS:GD,QT,KT,BH:CP', min_write_label => 'C', def_label => 'HS:GD,QT,KT,BH:CP', row_label => 'HS:GD,QT,KT,BH:CP');
EXECUTE SA_USER_ADMIN.SET_USER_LABELS (policy_name => 'CHINHSACH', user_name => 'admin', max_read_label => 'HS:QT,KT,BH:AD', max_write_label => 'HS:QT,KT,BH:AD', min_write_label => 'C', def_label => 'HS:QT,KT,BH:AD', row_label => 'HS:QT,KT,BH:AD');
EXECUTE SA_USER_ADMIN.SET_USER_LABELS (policy_name => 'CHINHSACH', user_name => 'kt_quanly1', max_read_label => 'S:KT:QL', max_write_label => 'S:KT:QL', min_write_label => 'C', def_label => 'S:KT:QL', row_label => 'S:KT:QL');
EXECUTE SA_USER_ADMIN.SET_USER_LABELS (policy_name => 'CHINHSACH', user_name => 'bh_quanly1', max_read_label => 'S:BH:QL', max_write_label => 'S:BH:QL', min_write_label => 'C', def_label => 'S:BH:QL', row_label => 'S:BH:QL');
EXECUTE SA_USER_ADMIN.SET_USER_LABELS (policy_name => 'CHINHSACH', user_name => 'kt_nhanvien1', max_read_label => 'C:KT:NV', max_write_label => 'C:KT:NV', min_write_label => 'C', def_label => 'C:KT:NV', row_label => 'C:KT:NV');
EXECUTE SA_USER_ADMIN.SET_USER_LABELS (policy_name => 'CHINHSACH', user_name => 'bh_nhanvien1', max_read_label => 'C:BH:NV', max_write_label => 'C:BH:NV', min_write_label => 'C', def_label => 'C:BH:NV', row_label => 'C:BH:NV');
COMMIT;

--Gán nhãn bảo mật cho bảng Nhân Sự
UPDATE caphe.NHANSU SET OLS_COLUMN = char_to_label('CHINHSACH', 'HS:GD,QT,KT,BH:CP') WHERE PHONG = 'GIAM DOC' AND CHUCVU = 'CA PHE';
UPDATE caphe.NHANSU SET OLS_COLUMN = char_to_label('CHINHSACH', 'HS:QT,KT,BH:AD') WHERE PHONG = 'QUAN TRI' AND CHUCVU = 'ADMIN';
UPDATE caphe.NHANSU SET OLS_COLUMN = char_to_label('CHINHSACH', 'S:KT:QL') WHERE PHONG = 'KE TOAN' AND CHUCVU = 'QUAN LY';
UPDATE caphe.NHANSU SET OLS_COLUMN = char_to_label('CHINHSACH', 'C:KT:NV') WHERE PHONG = 'KE TOAN' AND CHUCVU = 'NHAN VIEN';
UPDATE caphe.NHANSU SET OLS_COLUMN = char_to_label('CHINHSACH', 'S:BH:QL') WHERE PHONG = 'BAN HANG' AND CHUCVU = 'QUAN LY';
UPDATE caphe.NHANSU SET OLS_COLUMN = char_to_label('CHINHSACH', 'C:BH:NV') WHERE PHONG = 'BAN HANG' AND CHUCVU = 'NHAN VIEN';

--Gán nhãn bảo mật cho bảng Tài Khoản
UPDATE caphe.TAIKHOAN SET OLS_COLUMN = char_to_label('CHINHSACH', 'HS:GD,QT,KT,BH:CP') WHERE TENDANGNHAP = (SELECT TAIKHOAN FROM caphe.NHANSU WHERE PHONG = 'GIAM DOC' AND CHUCVU = 'CA PHE');
UPDATE caphe.TAIKHOAN SET OLS_COLUMN = char_to_label('CHINHSACH', 'HS:QT,KT,BH:AD') WHERE TENDANGNHAP = (SELECT TAIKHOAN FROM caphe.NHANSU WHERE PHONG = 'QUAN TRI' AND CHUCVU = 'ADMIN');
UPDATE caphe.TAIKHOAN SET OLS_COLUMN = char_to_label('CHINHSACH', 'S:KT:QL') WHERE TENDANGNHAP = (SELECT TAIKHOAN FROM caphe.NHANSU WHERE PHONG = 'KE TOAN' AND CHUCVU = 'QUAN LY');
UPDATE caphe.TAIKHOAN SET OLS_COLUMN = char_to_label('CHINHSACH', 'C:KT:NV') WHERE TENDANGNHAP = (SELECT TAIKHOAN FROM caphe.NHANSU WHERE PHONG = 'KE TOAN' AND CHUCVU = 'NHAN VIEN');
UPDATE caphe.TAIKHOAN SET OLS_COLUMN = char_to_label('CHINHSACH', 'S:BH:QL')  WHERE TENDANGNHAP = (SELECT TAIKHOAN FROM caphe.NHANSU WHERE PHONG = 'BAN HANG' AND CHUCVU = 'QUAN LY');
UPDATE caphe.TAIKHOAN SET OLS_COLUMN = char_to_label('CHINHSACH', 'C:BH:NV') WHERE TENDANGNHAP = (SELECT TAIKHOAN FROM caphe.NHANSU WHERE PHONG = 'BAN HANG' AND CHUCVU = 'NHAN VIEN');



