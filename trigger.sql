USE cellgo;

DELIMITER $$

/* Validação antes de cadastrar um cliente */
CREATE TRIGGER trg_cliente_idade_insert
BEFORE INSERT ON CLIENTE
FOR EACH ROW
BEGIN
    IF NEW.Tipo_Pessoa = 'PF' THEN
        IF NEW.Data_Nascimento IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT =
                    'Informe a data de nascimento do cliente PF.';

        ELSEIF TIMESTAMPDIFF(
            YEAR,
            NEW.Data_Nascimento,
            CURDATE()
        ) < 18 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT =
                    'O cliente PF deve ter pelo menos 18 anos.';
        END IF;
    END IF;
END$$

/* Validação antes de atualizar um cliente */
CREATE TRIGGER trg_cliente_idade_update
BEFORE UPDATE ON CLIENTE
FOR EACH ROW
BEGIN
    IF NEW.Tipo_Pessoa = 'PF' THEN
        IF NEW.Data_Nascimento IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT =
                    'Informe a data de nascimento do cliente PF.';

        ELSEIF TIMESTAMPDIFF(
            YEAR,
            NEW.Data_Nascimento,
            CURDATE()
        ) < 18 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT =
                    'O cliente PF deve ter pelo menos 18 anos.';
        END IF;
    END IF;
END$$

DELIMITER ;


/* Não deixa entrar com fim data de garantia fabricante para celulares semi-novos */
DELIMITER $$

CREATE TRIGGER trg_item_pedido_garantia_bi
BEFORE INSERT ON item_pedido
FOR EACH ROW
BEGIN
  IF NEW.Data_Fim_Garantia_Fabricante IS NOT NULL
     AND (SELECT Condicao FROM aparelho WHERE Imei = NEW.Imei) = 'Seminovo' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Aparelho seminovo não possui garantia de fabricante';
  END IF;
END$$

CREATE TRIGGER trg_item_pedido_garantia_bu
BEFORE UPDATE ON item_pedido
FOR EACH ROW
BEGIN
  IF NEW.Data_Fim_Garantia_Fabricante IS NOT NULL
     AND (SELECT Condicao FROM aparelho WHERE Imei = NEW.Imei) = 'Seminovo' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Aparelho seminovo não possui garantia de fabricante';
  END IF;
END$$

DELIMITER ;