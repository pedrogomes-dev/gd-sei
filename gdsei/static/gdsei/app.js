"use strict";

document.querySelectorAll("select[data-visualizar]").forEach(select => {
  let anterior = select.value;
  select.addEventListener("change", async () => {
    if (!select.value || !select.dataset.visualizar) return;
    const form = select.closest("form");
    try {
      const response = await fetch(select.dataset.visualizar, {method: "POST", credentials: "same-origin", headers: {"X-CSRFToken": form.querySelector('[name="csrfmiddlewaretoken"]').value}});
      if (!response.ok || response.redirected) throw new Error("Não foi possível registrar a visualização. Recarregue ou faça login novamente.");
      delete select.dataset.visualizar;
      anterior = select.value;
    } catch (error) {
      select.value = anterior;
      window.alert(error.message);
    }
  });
});

document.querySelectorAll("[data-dialog]").forEach(button => {
  button.addEventListener("click", () => document.getElementById(button.dataset.dialog).showModal());
});
document.querySelectorAll("[data-fechar]").forEach(button => {
  button.addEventListener("click", () => button.closest("dialog").close());
});
document.querySelectorAll("[data-estrutural]").forEach(button => {
  button.addEventListener("click", event => {
    event.preventDefault();
    window.alert("Item apenas estrutural. Não pode ser vinculado a Tipos de Processo.");
  });
});
document.querySelectorAll("[data-filtrar]").forEach(input => {
  input.addEventListener("input", () => {
    const texto = input.value.toLocaleLowerCase("pt-BR");
    document.getElementById(input.dataset.filtrar).querySelectorAll("[data-pesquisa]").forEach(item => {
      item.hidden = !item.dataset.pesquisa.toLocaleLowerCase("pt-BR").includes(texto);
    });
  });
});
document.querySelectorAll("form[data-edicao]").forEach(form => {
  let alterado = false;
  form.addEventListener("change", () => { alterado = true; });
  form.addEventListener("input", () => { alterado = true; });
  form.addEventListener("submit", () => { alterado = false; });
  window.addEventListener("beforeunload", event => {
    if (alterado) { event.preventDefault(); event.returnValue = ""; }
  });
});
document.querySelectorAll("form[data-confirmar]").forEach(form => {
  form.addEventListener("submit", event => {
    if (!window.confirm(form.dataset.confirmar)) event.preventDefault();
  });
});
// Seleção em lote atravessa páginas/filtros; armazenar somente IDs no navegador.
document.querySelectorAll("form[data-selecao]").forEach(form => {
  const chave = "gdsei-" + form.dataset.selecao;
  let selecionados;
  try { selecionados = new Set(JSON.parse(sessionStorage.getItem(chave) || "[]")); }
  catch { selecionados = new Set(); }
  const checks = [...form.querySelectorAll('input[name="tipos"]')];
  const atualizar = () => {
    checks.forEach(check => { check.checked = selecionados.has(check.value); });
    form.querySelector("[data-contagem]").textContent = selecionados.size + " selecionados";
    try { sessionStorage.setItem(chave, JSON.stringify([...selecionados])); } catch { /* Sem armazenamento, seleção da página continua funcionando. */ }
  };
  checks.forEach(check => check.addEventListener("change", () => {
    if (check.checked) selecionados.add(check.value); else selecionados.delete(check.value);
    atualizar();
  }));
  form.querySelector("[data-todos]").addEventListener("change", event => {
    checks.forEach(check => { if (event.target.checked) selecionados.add(check.value); else selecionados.delete(check.value); });
    atualizar();
  });
  form.querySelector("[data-limpar]").addEventListener("click", () => { selecionados.clear(); atualizar(); });
  form.addEventListener("submit", () => {
    const visiveis = new Set(checks.map(check => check.value));
    selecionados.forEach(id => {
      if (!visiveis.has(id)) {
        const input = document.createElement("input"); input.type = "hidden"; input.name = "tipos"; input.value = id; form.appendChild(input);
      }
    });
  });
  atualizar();
});
