/* Atividade laboratório
Aluno: Matheus da Silva
ADS - 3
*/

-- Questão 2
CREATE OR REPLACE PROCEDURE inserir_funcionario (
  p_fname company.employee.fname%TYPE,
  p_minit company.employee.minit%TYPE,
  P_lname company.employee.lname%TYPE,
  p_ssn company.employee.ssn%TYPE,
  p_bdate company.employee.bdate%TYPE,
  p_address company.employee.address%TYPE,
  p_sex company.employee.sex%TYPE,
  p_salary company.employee.salary%TYPE,
  P_superssn company.employee.superssn%TYPE,
  p_dno company.employee.dno%TYPE
) 
LANGUAGE plpgsql
AS $$
BEGIN
  -- Verificar se o SSN já existe
  IF EXISTS (SELECT 1 FROM company.employee WHERE ssn = p_ssn) THEN
    RAISE EXCEPTION 'SSN já existe para outro funcionário';
  END IF;

  INSERT INTO company.employee (fname, minit, lname, ssn, bdate, address, sex, salary, superssn, dno) 
  VALUES (p_fname, p_minit, p_lname, p_ssn, p_bdate, p_address, p_sex, p_salary, p_superssn, p_dno);
END;
$$;

-- Questão 3
CALL inserir_funcionario(
  'John',
  'D',
  'Doe',
  '123456789',
  '1980-01-01',
  '123 Main St, Anytown, USA',
  'M',         
  60000,       
  '987654321', 
  5            
);

-- Questão 4
CREATE OR REPLACE PROCEDURE listar_departamentos()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
BEGIN
    CREATE TEMP TABLE lista_departamentos AS
    SELECT
        d.dname AS nome_departamento,
        COUNT(e.ssn) AS quantidade_funcionarios,
        SUM(e.salary) AS salario_total
    FROM
        department d
    LEFT JOIN
        employee e ON d.dnumber = e.dno
    GROUP BY
        d.dname;

    UPDATE lista_departamentos
    SET salario_total = 0
    WHERE salario_total IS NULL;
    
    FOR rec IN
        SELECT * FROM lista_departamentos
    LOOP
        RAISE NOTICE 'Departamento: %, Funcionários: %, Salário Total: %', 
            rec.nome_departamento, rec.quantidade_funcionarios, rec.salario_total;
    END LOOP;

    DROP TABLE lista_departamentos;
END;
$$;

CALL listar_departamentos();

-- Questão 5
CREATE OR REPLACE PROCEDURE inserir_departamento(
  p_dname company.department.dname%TYPE,
  p_dnumber company.department.dnumber%TYPE,
  p_mgrssn company.department.mgrssn%TYPE,
  p_mgrstartdate company.department.mgrstartdate%TYPE
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_departamento_existe BOOLEAN;
  v_funcionario_existe BOOLEAN;
BEGIN
  -- Verificar se o departamento já existe
  SELECT EXISTS (SELECT 1 FROM company.department WHERE dname = p_dname) INTO v_departamento_existe;
  
  IF v_departamento_existe THEN
    RAISE EXCEPTION 'Departamento com o nome % já existe.', p_dname;
  END IF;

  -- Verificar se o número do departamento já existe
  SELECT EXISTS (SELECT 1 FROM company.department WHERE dnumber = p_dnumber) INTO v_departamento_existe;
  
  IF v_departamento_existe THEN
    RAISE EXCEPTION 'Departamento com o número % já existe.', p_dnumber;
  END IF;

  -- Verificar se o gerente (mgrssn) existe na tabela employee
  SELECT EXISTS (SELECT 1 FROM company.employee WHERE ssn = p_mgrssn) INTO v_funcionario_existe;
  
  IF NOT v_funcionario_existe THEN
    RAISE EXCEPTION 'Funcionário com SSN % não existe.', p_mgrssn;
  END IF;

  -- Inserir o novo departamento
  INSERT INTO company.department (dname, dnumber, mgrssn, mgrstartdate)
  VALUES (p_dname, p_dnumber, p_mgrssn, p_mgrstartdate);
END;
$$;

CALL inserir_departamento('NewDepartment', 6, '123456789', '2024-07-15');

-- Questão 6
CREATE OR REPLACE PROCEDURE alterar_gerente(
    p_dnumber company.department.dnumber%TYPE,
    p_mgrssn company.department.mgrssn%TYPE,
    p_mgrstartdate company.department.mgrstartdate%TYPE
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificar se o departamento existe
    IF NOT EXISTS (SELECT 1 FROM department WHERE dnumber = p_dnumber) THEN
        RAISE EXCEPTION 'Departamento não encontrado.';
    END IF;

    -- Verificar se o novo gerente é um funcionário válido
    IF p_mgrssn IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM employee WHERE ssn = p_mgrssn) THEN
            RAISE EXCEPTION 'O SSN do gerente não corresponde a um funcionário existente.';
        END IF;
    END IF;

    UPDATE department
    SET mgrssn = p_mgrssn,
        mgrstartdate = p_mgrstartdate
    WHERE dnumber = p_dnumber;
END;
$$;

CALL alterar_gerente(6, '453453453', DATE '2024-07-16');