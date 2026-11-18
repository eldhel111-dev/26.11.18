-- sportscenter seed.sql 베이스로 제작


-- 1번
-- 1970년~1989년에 태어난 회원 중 이메일이 등록되지 않은 회원을 찾아, 전화로 이메일을 받아 둘 명단을 만드세요.
-- - 사용 테이블: `members`
-- - 조건: 출생연도 1970~1989(양 끝 포함), 이메일 없음
-- - 정렬: 출생연도 오름차순, 같으면 회원번호 오름차순
SELECT 
    email,
    member_id           AS 회원번호 ,
    name                AS 이름 ,
    birth_year          AS 출생연도 ,
    phone               AS 전화번호
FROM members
WHERE birth_year BETWEEN 1970 AND 1989 AND email IS NULL
ORDER BY birth_year, member_id;

--  email | 회원번호 |  이름  | 출생연도 |   전화번호    
-- -------+----------+--------+----------+---------------
--        |       13 | 서승현 |     1971 | 010-3849-3947
--        |       58 | 황은찬 |     1977 | 010-8298-8042
--        |       32 | 안다은 |     1979 | 010-8286-3025
--        |       27 | 권우진 |     1984 | 010-7057-6561
--        |       38 | 송유나 |     1984 | 010-2410-8343
--        |       42 | 강나연 |     1985 | 010-8828-6655
--        |       47 | 박민재 |     1986 | 010-7337-6743
--        |        2 | 이준호 |     1988 | 010-2345-6789



-- 2번
-- 거주 지역과 성별로 회원을 묶어, 회원이 5명 이상인 묶음의 회원 수와 평균 출생연도를 구하세요. 성별은 'F', 'M' 대신 '여', '남'으로 보여 줍니다.
-- 사용 테이블: `members`
-- 조건: 회원 수가 5명 이상인 (거주지역, 성별) 묶음만
-- 정렬: 거주지역 오름차순, 같으면 성별 오름차순('남' → '여') 
SELECT 
    region                  AS 거주지역 ,
        CASE WHEN gender = 'F' THEN '여자'
             WHEN gender = 'M' THEN '남자'
             END AS 성별,
    COUNT(*)                AS 회원수 ,
    AVG(birth_year)         AS 평균출생년도
FROM members
GROUP BY region,gender
HAVING COUNT(*) >= 5
ORDER BY region COLLATE "ko-x-icu", 성별;


--  거주지역 | 성별 | 회원수 |     평균출생년도      
-- ----------+------+--------+-----------------------
--  마포구   | 남자 |      7 | 1978.2857142857142857
--  마포구   | 여자 |     10 | 1982.2000000000000000
--  서대문구 | 남자 |     11 | 1981.7272727272727273
--  서대문구 | 여자 |     11 | 1974.5454545454545455
--  용산구   | 남자 |      5 | 1981.0000000000000000
--  은평구   | 남자 |      6 | 1985.1666666666666667
-- 출생년도 반올림 충족 못함



-- 3번
-- 2026년 10월에 수강을 취소한 기록을 찾아, 다시 안내 전화를 할 수 있도록 회원 이름, 전화번호와 취소한 강좌명을 함께 보여 주세요.
-- - **사용 테이블:** `enrollments`, `members`, `courses`
-- - **조건:** 수강월 '2026-10', 상태(`status`) '취소'
-- - **정렬:** 회원명 오름차순
SELECT 
    m.name                   AS 회원명 ,
    m.phone                  AS 전화번호 ,
    c.course_name            AS 강좌명 ,
    e.enroll_month           AS 수강월
FROM enrollments e                                      -- JOIN 할때 SELECT FROM ~~ 부터
LEFT JOIN members m ON e.member_id = m.member_id
LEFT JOIN courses c ON e.course_id = c.course_id
WHERE enroll_month = '2026-10' AND status = '취소'
ORDER BY name;

--  회원명 |   전화번호    |     강좌명      | 수강월  
-- --------+---------------+-----------------+---------
--  권채원 | 010-9996-6251 | 실버 스포츠댄스 | 2026-10
--  송유나 | 010-2410-8343 | 볼룸댄스 중급   | 2026-10
--  신서현 | 010-9986-3612 | 골프 입문반     | 2026-10



-- 4번
-- 종목 이름과 수강월별로 실제 수강 인원과 매출을 구하고, 매출이 100만 원 이상인 경우만 보여 주세요. 취소된 기록은 수강 인원에서 빼야 합니다.
-- 사용 테이블: `enrollments`, `courses`, `sports`
-- 조건: 취소 기록 제외, 매출이 1,000,000원 이상인 (종목, 수강월)만
-- 정렬: 종목 오름차순, 같으면 수강월 오름차순
-- 힌트: `enrollments`에는 종목 정보가 없습니다. 어떤 테이블을 거쳐야 `sports`에 닿는지 ERD에서 찾아보세요.
SELECT
    course_name            AS 종목,
    enroll_month           AS 수강월,
    COUNT(*)               AS 수강인원,  
    paid.total_paid             AS 매출액
FROM (
      SELECT course_id, SUM(pay_amount) AS total_paid          -- 안에 기능부터 작동 확인
      FROM enrollments
      GROUP BY course_id
) AS paid
WHERE paid.total_paid > 1000000
ORDER BY c.course_name, enroll_month;
-- 모르겠음





-- 5번
-- 강사마다 담당 강좌 수와, 담당 강좌의 이번 달(2026-11) 수강 신청 건수를 구하세요. 맡은 강좌가 없는 강사도 결과에 나와야 하며, 이때 두 값은 0입니다.
-- 사용 테이블: `instructors`, `sports`, `courses`, `enrollments`
-- 조건: 강사 8명이 모두 나와야 함
-- 정렬: 이번달신청 내림차순, 같으면 강사명 오름차순
SELECT
    name            AS 강사명,
    s.sport_name       AS 종목,
    COUNT(*)         AS 담당강좌수
    -- ??                AS 이번달신청
FROM instructors i
LEFT JOIN sports s ON s.sport_id = i.sport_id
GROUP BY name, s.sport_id;
ORDER BY -- ?? DESC, name 



-- HAVING JOIN SUB QUERY의 개념은 이해했으나 활용과 어떻게 적용하는지 아직 잘 모르겠음
-- 할때마다 테이블에 있는 요소들이 기억이안나 \d 를 통해 알아 보아 시간이 부족했음